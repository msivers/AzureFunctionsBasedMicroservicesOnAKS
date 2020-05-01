using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Env = System.Environment;

using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using RevolutionPlatform.RPLCommon;
using RevolutionPlatform.RPLHelpers;

namespace SampleServices.Services.UserService
{
    public class B2CGraphClient : IB2CGraphClient
    {
        private static HttpClient httpClient = new HttpClient();

        // Private variables for Azure AD Graph API (B2C Integration)
        private static string aadGraphResourceId = "https://graph.windows.net/";
        private static string aadGraphEndpoint = "https://graph.windows.net/";
        private static string aadGraphVersion = "api-version=1.6"; // For B2C user management, be sure to use the 1.6 Graph API version.
        private static string aadTenant = Env.GetEnvironmentVariable("B2CGraphApiTenant");
        private static string aadClientId = Env.GetEnvironmentVariable("B2CGraphApiClientId");
        private static string aadClientSecret = Env.GetEnvironmentVariable("B2CGraphApiClientSecret");
        private static AuthenticationContext authContext = new AuthenticationContext($"https://login.microsoftonline.com/{aadTenant}");
        private static ClientCredential credential = new ClientCredential(aadClientId, aadClientSecret);

        public async Task<string> GetUserByObjectId(string objectId, ILogger log)
        {
            return await SendGraphGetRequest($"/users/{objectId}", null, log);
        }

        public async Task<string> GetAllUsers(string query, ILogger log)
        {
            return await SendGraphGetRequest("/users/", query, log);
        }

        public async Task<string> CreateUser(B2CUser user, ILogger log)
        {
            return await SendGraphPostRequest("/users/", user, log);
        }

        public async Task<string> UpdateUser(string objectId, string json, ILogger log)
        {
            return await SendGraphPatchRequest($"/users/{objectId}", json, log);
        }

        public async Task<string> DeleteUser(string objectId, ILogger log)
        {
            return await SendGraphDeleteRequest($"/users/{objectId}", log);
        }

        public async Task<string> SendGraphGetRequest(string api, string query, ILogger log)
        {
            AuthenticationResult result = await authContext.AcquireTokenAsync(aadGraphResourceId, credential);
            string url = $"{aadGraphEndpoint}{aadTenant}{api}?{aadGraphVersion}";

            if (!string.IsNullOrEmpty(query))
            {
                url += "&" + query;
            }

            log.LogInformation($"GET {url}");
            log.LogDebug($"Authorization: Bearer {result.AccessToken.Substring(0, 20)}...");

            // Append the access token for the Graph API to the Authorization header of the request, using the Bearer scheme.
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Get, url);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", result.AccessToken);
            HttpResponseMessage response = await httpClient.SendAsync(request);

            if (!response.IsSuccessStatusCode)
            {
                string error = await response.Content.ReadAsStringAsync();
                object formatted = JsonConvert.DeserializeObject(error);
                throw new WebException($"Error calling the AD Graph API: \n{JsonConvert.SerializeObject(formatted, Formatting.Indented)}");
            }

            log.LogInformation($"{(int)response.StatusCode}: {response.ReasonPhrase}");

            return await response.Content.ReadAsStringAsync();
        }

        private async Task<string> SendGraphPostRequest(string api, B2CUser user, ILogger log)
        {
            AuthenticationResult result = await authContext.AcquireTokenAsync(aadGraphResourceId, credential);
            string url = $"{aadGraphEndpoint}{aadTenant}{api}?{aadGraphVersion}";

            log.LogInformation($"POST {url}");
            log.LogDebug($"Authorization: Bearer {result.AccessToken.Substring(0, 20)}...");

            JsonSerializerSettings B2CJsonSerializerSettings = new JsonSerializerSettings { ContractResolver = new B2CUserAttributeContractResolver() };
            var serializedB2CUser = JsonConvert.SerializeObject(user, B2CJsonSerializerSettings);

            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", result.AccessToken);
            request.Content = new StringContent(serializedB2CUser, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await httpClient.SendAsync(request);

            if (!response.IsSuccessStatusCode)
            {
                string errorJson = await response.Content.ReadAsStringAsync();
                var error = JsonConvert.DeserializeObject<B2CErrorRoot>(errorJson).Error;

                if (error.Code == "Request_BadRequest" && (error.Values?.Any(x => x.Item == "PropertyName" && x.Value == "signInNames") ?? false))
                {
                    throw new B2CUserExistsException($"B2C user '{user?.SignInNames[0]?.Value}' already exists.");
                }
                else
                {
                    throw new WebException($"Error Calling the Graph API: \n{JsonConvert.SerializeObject(error, Formatting.Indented)}");
                }
            }

            log.LogInformation($"{(int)response.StatusCode}: {response.ReasonPhrase}");

            return await response.Content.ReadAsStringAsync();
        }

        private async Task<string> SendGraphPatchRequest(string api, string json, ILogger log)
        {
            AuthenticationResult result = await authContext.AcquireTokenAsync(aadGraphResourceId, credential);
            string url = $"{aadGraphEndpoint}{aadTenant}{api}?{aadGraphVersion}";

            log.LogInformation($"PATCH {url}");
            log.LogDebug($"Authorization: Bearer {result.AccessToken.Substring(0, 20)}...");
            log.LogInformation("Content-Type: application/json");
            log.LogInformation(json);

            HttpRequestMessage request = new HttpRequestMessage(new HttpMethod("PATCH"), url);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", result.AccessToken);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await httpClient.SendAsync(request);

            if (!response.IsSuccessStatusCode)
            {
                string errorJson = await response.Content.ReadAsStringAsync();
                var error = JsonConvert.DeserializeObject<B2CErrorRoot>(errorJson).Error;

                if (error.Code == "Request_BadRequest" && error.Message.Value.Contains("password complexity"))
                {
                    throw new B2CPasswordComplexityException($"B2C password complexity requirement not met.");
                }
                else
                {
                    throw new WebException($"Error Calling the Graph API: \n{JsonConvert.SerializeObject(error, Formatting.Indented)}");
                }
            }

            log.LogInformation($"{(int)response.StatusCode}: {response.ReasonPhrase}");

            return await response.Content.ReadAsStringAsync();
        }

        private async Task<string> SendGraphDeleteRequest(string api, ILogger log)
        {
            AuthenticationResult result = await authContext.AcquireTokenAsync(aadGraphResourceId, credential);
            string url = $"{aadGraphEndpoint}{aadTenant}{api}?{aadGraphVersion}";

            log.LogInformation($"DELETE {url}");
            log.LogDebug($"Authorization: Bearer {result.AccessToken.Substring(0, 20)}...");

            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Delete, url);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", result.AccessToken);
            HttpResponseMessage response = await httpClient.SendAsync(request);

            if (!response.IsSuccessStatusCode)
            {
                string error = await response.Content.ReadAsStringAsync();
                object formatted = JsonConvert.DeserializeObject(error);

                throw new WebException($"Error Calling the Graph API: \n{JsonConvert.SerializeObject(formatted, Formatting.Indented)}");
            }

            log.LogInformation($"{(int)response.StatusCode}: {response.ReasonPhrase}");

            return await response.Content.ReadAsStringAsync();
        }
    }
}