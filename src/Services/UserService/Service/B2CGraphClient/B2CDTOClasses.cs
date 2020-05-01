using System;
using System.Collections.Generic;

using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace SampleServices.Services.UserService
{
    public class B2CUser
    {
        /// <summary>
        /// Object Id of identity. Typically a guid value as string.
        /// </summary>
        [JsonProperty(PropertyName = "objectId")]
        public string ObjectId { get; set; }

        /// <summary>
        /// true if the account is enabled; otherwise, false.
        /// </summary>
        [JsonProperty(PropertyName = "accountEnabled")]
        public bool AccountEnabled { get; set; } = true;

        /// <summary>
        /// Controls which identifier the user uses to sign in to the account.
        /// One or more SignInName records that specify the sign-in names for the user. Each sign-in name must be unique across the company/tenant.
        /// </summary>
        [JsonProperty(PropertyName = "signInNames")]
        public List<B2CSignInName> SignInNames { get; set; } = new List<B2CSignInName>();

        /// <summary>
        /// Must be set to 'LocalAccount' to create a local account user.
        /// </summary>
        [JsonProperty(PropertyName = "creationType")]
        public string CreationType { get; set; } = "LocalAccount";

        /// <summary>
        /// The name to display in the address book for the user.
        /// </summary>
        [JsonProperty(PropertyName = "displayName")]
        public string DisplayName { get; set; }

        /// <summary>
        /// The password profile for the user.
        /// </summary>
        [JsonProperty(PropertyName = "passwordProfile")]
        public B2CPasswordProfile PasswordProfile { get; set; } = new B2CPasswordProfile();

        /// <summary>
        /// Specifies password policies for the user.
        /// Options are "DisableStrongPassword" and/or "DisablePasswordExpiration", or "None" or null.
        /// Smample: "DisablePasswordExpiration, DisableStrongPassword".
        /// </summary>
        [JsonProperty(PropertyName = "passwordPolicies")]
        public string PasswordPolicies { get; set; } = "DisablePasswordExpiration";

        /// <summary>
        /// Revolution Platform User Id - B2C Custom User Attribute.
        /// </summary>

        public string UserAttribute_CustomerUserId { get; set; }
    }

    public class B2CSignInName
    {
        /// <summary>
        /// A string value that can be used to classify user sign-in types in your directory, such as "emailAddress" or "userName".
        /// </summary>
        [JsonProperty(PropertyName = "type")]
        public string Type { get; set; }

        /// <summary>
        /// The sign-in used by the local account. Must be unique across the company/tenant. For example, "johnc@example.com".
        /// </summary>
        [JsonProperty(PropertyName = "value")]
        public string Value { get; set; }
    }

    public class B2CPasswordProfile
    {
        /// <summary>
        /// The password for the user. This property is required when a user is created. It can be updated, but the user will be required to change the password on the next login. 
        /// 
        /// The password must satisfy minimum requirements as specified by the user's PasswordPolicies property. By default, a strong password is required. The password property is write only.
        /// </summary>
        [JsonProperty(PropertyName = "password")]
        public string Password { get; set; } = Guid.NewGuid().ToString();

        /// <summary>
        /// true if the user must change her password on the next login; otherwise false.
        /// </summary>
        [JsonProperty(PropertyName = "forceChangePasswordNextLogin")]
        public bool ForceChangePasswordNextLogin { get; set; } = false;
    }

    public class B2CErrorRoot
    {
        [JsonProperty(PropertyName = "odata.error")]
        public B2CError Error { get; set; }
    }

    public class B2CError
    {
        [JsonProperty(PropertyName = "code")]
        public string Code { get; set; }

        [JsonProperty(PropertyName = "message")]
        public B2CErrorMessage Message { get; set; }

        [JsonProperty(PropertyName = "date")]
        public DateTime Date { get; set; }

        [JsonProperty(PropertyName = "requestId")]
        public string RequestId { get; set; }

        [JsonProperty(PropertyName = "values")]
        public List<B2CErrorValue> Values { get; set; }
    }

    public class B2CErrorMessage
    {
        [JsonProperty(PropertyName = "lang")]
        public string Lang { get; set; }

        [JsonProperty(PropertyName = "value")]
        public string Value { get; set; }
    }

    public class B2CErrorValue
    {
        [JsonProperty(PropertyName = "item")]
        public string Item { get; set; }

        [JsonProperty(PropertyName = "value")]
        public string Value { get; set; }
    }

    public class B2CUserExistsException : Exception
    {
        public B2CUserExistsException()
        {
        }

        public B2CUserExistsException(string message) : base(message)
        {
        }

        public B2CUserExistsException(string message, Exception inner) : base(message, inner)
        {
        }
    }

    public class B2CPasswordComplexityException : Exception
    {
        public B2CPasswordComplexityException()
        {
        }

        public B2CPasswordComplexityException(string message) : base(message)
        {
        }

        public B2CPasswordComplexityException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}