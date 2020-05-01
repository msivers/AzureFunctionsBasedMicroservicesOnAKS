using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using IHttpClientFactory = System.Net.Http.IHttpClientFactory;

using AzureExtensions.FunctionToken;
using AzureExtensions.FunctionToken.FunctionBinding.Enums;
using Gremlin.Net.Driver;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;

namespace SampleServices.Services.UserService
{
    public abstract class UserServiceBase
    {
        private const string NotProvidedString = "NOTPROVIDED";
        private const string B2CUserAttributeName_CustomerUserId = "extension_CustomerUserId";

        public TelemetryClient TelemetryClient;
        public IGremlinClient GremlinClient;
        public IB2CGraphClient B2CGraphClient;

        public UserServiceBase(IHttpClientFactory httpClientFactory, IGremlinClient gremlinClient, IB2CGraphClient b2cGraphClient, TelemetryConfiguration telemetryConfiguration)
        {
            TelemetryClient = new TelemetryClient(telemetryConfiguration);
            GremlinClient = gremlinClient;
            B2CGraphClient = b2cGraphClient;
        }

        internal (bool IsAuthorized, IActionResult ActionResult) AuthValidation(HttpRequest req, FunctionTokenResult token, string id = NotProvidedString)
        {
            // IMPORTANT: Returning null should indicate that authorization has been confirmed!

            if (token.Status == TokenStatus.Valid)
            {
                if (token.Principal.IsInRole("Admin"))
                    return (true, null); // User is authorized because token is valid and user is in Admin role.

                if (id == NotProvidedString)
                    return (true, null); // User is authorized because token is valid and no id has been provided to check.

                var claimIdpIdentity = token.Principal.Claims.FirstOrDefault(x => x.Type == ClaimTypes.NameIdentifier);
                var claimCustomerUserId = token.Principal.Claims.FirstOrDefault(x => x.Type == B2CUserAttributeName_CustomerUserId);

                if (id == claimCustomerUserId.Value)
                    return (true, null); // User is authorized because token is valid and requested user id matches customer user id .
                
                return (false, new StatusCodeResult(403)); // User is authorized but forbidden to access this content!
            }

            return (false, new UnauthorizedResult());
        }
    }
}