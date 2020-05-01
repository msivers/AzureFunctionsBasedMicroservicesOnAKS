using System;
using System.IO;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace RevolutionPlatform.DevOps.Utilities
{
    public static class Echo
    {
        [FunctionName("Echo")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = "echo/{phrase?}")] HttpRequest req,
            string phrase,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            // If no phrase is provided on route then use body (only if POST verb)
            if (string.IsNullOrWhiteSpace(phrase) && req.Method == "POST")
            {
                phrase = new StreamReader(req.Body).ReadToEnd();
            }

            // If no phrase still, then will just return "PING! {date}"
            if (string.IsNullOrWhiteSpace(phrase))
            {
                phrase = $"PING! {DateTime.UtcNow.ToString("s", System.Globalization.CultureInfo.InvariantCulture)}";
            }

            return phrase != null ?
                (ActionResult) new OkObjectResult($"{phrase}") :
                new BadRequestObjectResult("Please pass a phrase in the body to echo.");
        }
    }
}