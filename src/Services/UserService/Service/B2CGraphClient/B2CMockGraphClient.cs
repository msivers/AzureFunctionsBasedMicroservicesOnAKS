using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Threading.Tasks;

using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace SampleServices.Services.UserService
{
    public class B2CMockGraphClient : IB2CGraphClient
    {
        private Dictionary<string, B2CUser> users;

        public B2CMockGraphClient()
        {
            users = MockUsers();
        }

        public async Task<string> GetAllUsers(string query, ILogger log)
        {
            return await Task.Run(() => { return JsonConvert.SerializeObject(users); });
        }

        public async Task<string> GetUserByObjectId(string objectId, ILogger log)
        {
            return await Task.Run(() =>
            {
                if (users.ContainsKey(objectId.ToString()))
                    return (string)null;
                B2CUser user = users.GetValueOrDefault(objectId.ToString());
                return JsonConvert.SerializeObject(user);
            });
        }

        public async Task<string> CreateUser(B2CUser user, ILogger log)
        {
            return await Task.Run(() =>
            {
                user.ObjectId = Guid.NewGuid().ToString();
                users.Add(user.ObjectId, user);

                JsonSerializerSettings B2CJsonSerializerSettings = new JsonSerializerSettings { ContractResolver = new B2CUserAttributeContractResolver() };

                return JsonConvert.SerializeObject(user, B2CJsonSerializerSettings);
            });
        }

        public async Task<string> DeleteUser(string objectId, ILogger log)
        {
            return await Task.Run(() =>
            {
                users.Remove(objectId.ToString());
                return (string)null;
            });
        }

        public async Task<string> UpdateUser(string objectId, string json, ILogger log)
        {
            return await Task.Run(() =>
            {
                if (users.ContainsKey(objectId.ToString()))
                    return (string)null;

                B2CUser user = users.GetValueOrDefault(objectId.ToString());
                dynamic wrapper = JsonConvert.DeserializeObject<dynamic>(json);

                if (wrapper != null && IsDynamicPropertyExist(wrapper, "displayName"))
                {
                    user.DisplayName = wrapper.displayName;
                }

                if (wrapper != null && IsDynamicPropertyExist(wrapper, "passwordPolicies"))
                {
                    user.PasswordPolicies = wrapper.passwordPolicies;
                }

                if (wrapper != null && IsDynamicPropertyExist(wrapper, "passwordProfile"))
                {
                    user.PasswordProfile = wrapper.passwordProfile;
                }

                return (string)null;
            });
        }

        private Dictionary<string, B2CUser> MockUsers()
        {
            var users = new Dictionary<string, B2CUser>() {
                { "cf54a70e-1f7c-4ab2-a133-95489f694d22", new B2CUser() {
                    DisplayName = "Joe Bloggs",
                    SignInNames = new List<B2CSignInName>() {
                        new B2CSignInName() { Type = "userName", Value = "jbloggs" },
                        new B2CSignInName() { Type = "emailAddress", Value = "joe@bloggs.com" }
                    }
                }},
                { "100c388c-8ded-4d79-b69d-79c91cb3dd4d", new B2CUser() {
                    DisplayName = "Fred Perry",
                    SignInNames = new List<B2CSignInName>() {
                        new B2CSignInName() { Type = "userName", Value = "fredperry" },
                        new B2CSignInName() { Type = "emailAddress", Value = "fredperry@gmail.com" }
                    }
                }}
            };
            return users;
        }

        public static bool IsDynamicPropertyExist(dynamic settings, string name)
        {
            if (settings is ExpandoObject)
                return ((IDictionary<string, object>)settings).ContainsKey(name);

            return settings.GetType().GetProperty(name) != null;
        }
    }
}