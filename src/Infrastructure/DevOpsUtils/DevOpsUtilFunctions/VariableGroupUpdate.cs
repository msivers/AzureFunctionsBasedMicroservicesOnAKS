using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.TeamFoundation.DistributedTask.WebApi;
using Microsoft.VisualStudio.Services.Common;
using Microsoft.VisualStudio.Services.WebApi;
using Newtonsoft.Json;

using Env = System.Environment;

namespace RevolutionPlatform.DevOps.Utilities
{
    public static class VariableGroupUpdate
    {
        private static HttpClient client = new HttpClient();

        [FunctionName("VariableGroupUpdate")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "patch", Route = "variablegroup/{variableGroupName}/{variableKey}")] HttpRequest req,
            string variableGroupName,
            string variableKey,
            ILogger log,
            ExecutionContext context)
        {
            log.LogInformation($"RP DevOps Utils - {context.FunctionName} - Running...");

            string variableValue = new StreamReader(req.Body).ReadToEnd();

            Uri accountUri = new Uri(Env.GetEnvironmentVariable("DevOpsUri"));

            // Get Personal Access Token for Azure DevOps from KeyVault 
            var azureServiceTokenProvider = new AzureServiceTokenProvider();
            var kvClient = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback), client);
            string personalAccessToken = (await kvClient.GetSecretAsync(Env.GetEnvironmentVariable("KeyVaultUri"), Env.GetEnvironmentVariable("KeyVaultPatKeyName"))).Value;

            // Get specified Variables Group data from Azure DevOps
            VssConnection connection = new VssConnection(accountUri, new VssBasicCredential(string.Empty, personalAccessToken));
            TaskAgentHttpClient taClient = connection.GetClient<TaskAgentHttpClient>();
            var varGroups = await taClient.GetVariableGroupsAsync(Env.GetEnvironmentVariable("DevOpsProjectName"), variableGroupName);
            var variableGroup = varGroups.First();
            var newVariableValue = new VariableValue() { Value = variableValue };
            variableGroup.Variables.AddOrUpdate(variableKey, newVariableValue, (key, oldValue) => newVariableValue);

            VariableGroupParameters variableGroupParameters = new VariableGroupParameters()
            {
                Description = variableGroup.Description,
                Name = variableGroup.Name,
                ProviderData = variableGroup.ProviderData,
                Type = variableGroup.Type,
                Variables = variableGroup.Variables
            };

            await taClient.UpdateVariableGroupAsync(WebUtility.HtmlEncode(Env.GetEnvironmentVariable("DevOpsProjectName")), variableGroup.Id, variableGroupParameters);

            log.LogInformation($"RP DevOps Utils - {context.FunctionName} - Completed.");

            return (ActionResult) new OkResult();
        }
    }
}