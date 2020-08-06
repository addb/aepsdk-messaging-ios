/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation

struct MessagingConstants {
    
    static let logTag = "Messaging"
    static let name = "com.adobe.messaging"
    static let version = "0.0.1"
    
    struct Defaults {
        
        
        private init() {}
    }
    
    struct EventDataKeys {
        
        struct Identity {
            static let pushIdentifier = "pushidentifier"
            
            private init() {}
        }
        
        private init() {}
    }

    struct EventSources {
        static let sharedState = "com.adobe.eventSource.sharedState"
        static let requestContent = "com.adobe.eventSource.requestContent"
        static let responseContent = "com.adobe.eventSource.responseContent"
        static let os = "com.adobe.eventSource.os"
        
        private init() {}
    }
    
    struct EventTypes {
        static let hub = "com.adobe.eventType.hub"
        static let genericIdentity = "com.adobe.eventType.generic.identity"
        static let genericData = "com.adobe.eventType.generic.data"
        
        private init() {}
    }
    
/*
     we'll be temproarily using the json structure until platform extension is ready.
     at that point, we'll rely on xdm tool and platform to send this profile event,
     and the keys below can be safely removed.
     
https://github.com/adobe/xdm/blob/master/schemas/context/profile-push-notification-details.example.1.json
{
    "xdm:pushNotificationDetails": [
        {
            "xdm:appID": "75eafb7e-fa44-4514-86fc-221e32c5aef9",
            "xdm:token": "99156313-c9df-4e54-9c6c-5740f940c3ca",
            "xdm:platform": "apns",
            "xdm:blacklisted": false,
            "xdm:identity": {
                "xdm:namespace": {
                    "xdm:code": "ECID"
                },
                "xdm:xid":"92312748749128"
            }
        }
    ]
}
 */
    
    struct Temp {
        static let dccsEndpoint = "https://dcs.adobedc.net/collection/a4a946939737c99b4d09d43c570266d42d2ef62546aa84fe894bac71d8bf98f1"
        static let schemaUrl = "https://ns.adobe.com/acopprod1/schemas/28b3d7114b095f6aff015a71a6d6667a5f466fc7c9826000"
        static let orgId = "3E2A28175B8ED3720A495E23@AdobeOrg"
        static let datasetId = "5ee2aa2f239d341915e991ea"
        
        static let postBodyBase = "{\"header\":{\"schemaRef\":{\"id\":\"%@\",\"contentType\":\"application/vnd.adobe.xed-full+json;version=1.28\"},\"imsOrgId\":\"%@\",\"source\":{\"name\":\"mobile\"},\"datasetId\":\"%@\"},\"body\":{\"xdmMeta\":{\"schemaRef\":{\"id\":\"%@\",\"contentType\":\"application/vnd.adobe.xed-full+json;version=1.28\"}},\"xdmEntity\":{\"_acopprod1\":{\"primaryid\":\"%@\"},\"pushNotificationDetails\":[{\"appID\":\"com.mobile.messagingTest\",\"platform\":\"apns\",\"token\":\"%@\",\"blacklisted\":false,\"identiy\":{\"namespace\":{\"code\":\"ECID\"},\"xid\":\"%@\"}}]}}}"
        
        // push
        static let pushNotificationDetails = "pushNotificationDetails"
        static let appId = "appID"
        static let token = "token"
        static let platform = "platform"
        static let blacklisted = "blacklisted"
        static let identity = "identiy"
        static let namespace = "namespace"
        static let code = "code"
        static let xid = "xid"
                
        private init() {}
    }
    
    struct JsonValues {
        static let ecid = "ECID"
        static let apns = "apns"
        static let apnsSandbox = "apns-sandbox"
        
        private init() {}
    }
    
    struct SharedState {
                
        static let stateOwner = "stateowner"
        
        struct Configuration {
            static let name = "com.adobe.module.configuration"
            static let privacyStatus = "global.privacy"
            static let dccsHackEndpoint = "messaging.dccsHack"
            
            private init() {}
        }
        
        struct Identity {
            static let name = "com.adobe.module.identity"
            
            static let ecid = "mid"
            
            private init() {}
        }
        
        private init() {}
    }
    
    private init() {}
}