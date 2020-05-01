using Env = System.Environment;
using System;
using System.Reflection;
using System.Security.Claims;

using AzureExtensions.FunctionToken.Extensions;
using AzureExtensions.FunctionToken.FunctionBinding.Options;
using AzureFunctions.Extensions.Swashbuckle;
using Gremlin.Net.Driver;
using Gremlin.Net.Structure.IO.GraphSON;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Hosting;
using Microsoft.Extensions.DependencyInjection;

using SampleServices.Services.UserService;


[assembly: WebJobsStartup(typeof(Startup))]
namespace SampleServices.Services.UserService
{
    public class Startup : IWebJobsStartup
    {
        public void Configure(IWebJobsBuilder builder)
        {
            builder.AddSwashBuckle(Assembly.GetExecutingAssembly());

            builder.AddAzureFunctionsToken(new TokenAzureB2COptions()
            {
                AzureB2CSingingKeyUri = new Uri(Env.GetEnvironmentVariable("AuthSigningKey")),
                Audience = Env.GetEnvironmentVariable("AuthAudience"),
                Issuer = Env.GetEnvironmentVariable("AuthIssuer")
            });

            builder.Services.AddHttpClient();

            builder.Services.AddSingleton((s) =>
            {
                GremlinServer gremlinServer = new GremlinServer(Env.GetEnvironmentVariable("CosmosGremlinHost"),
                    int.Parse(Env.GetEnvironmentVariable("CosmosPort")),
                    enableSsl: true,
                    username: "/dbs/" + Env.GetEnvironmentVariable("CosmosDatabaseName") + "/colls/" + Env.GetEnvironmentVariable("CosmosGraphName"),
                    password: Env.GetEnvironmentVariable("CosmosKey"));

                IGremlinClient gremlinClient = new GremlinClient(gremlinServer, new GraphSON2Reader(), new GraphSON2Writer(), GremlinClient.GraphSON2MimeType);

                return gremlinClient;
            });

            builder.Services.AddSingleton((s) =>
            {
                IB2CGraphClient b2CGraphClient = new B2CGraphClient();

                return b2CGraphClient;
            });
        }
    }
}