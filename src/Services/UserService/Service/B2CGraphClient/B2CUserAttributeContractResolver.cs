using System;
using System.Reflection;
using Env = System.Environment;

using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace SampleServices.Services.UserService
{
    public class B2CUserAttributeContractResolver : DefaultContractResolver
    {
        public new static readonly B2CUserAttributeContractResolver Instance = new B2CUserAttributeContractResolver();

        protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
        {
            JsonProperty property = base.CreateProperty(member, memberSerialization);

            if (property.PropertyName.StartsWith("UserAttribute_"))
            {
                property.PropertyName = property.PropertyName.Replace("UserAttribute", $"extension_{Env.GetEnvironmentVariable("B2CGraphApiExtensionsAppId").Replace("-","")}");
            }

            return property;
        }
    }
}