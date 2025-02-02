//
// Copyright 2021 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import AEPCore
import AEPServices
import XCTest

@testable import AEPMessaging

class MessagingTests: XCTestCase {
    var messaging: Messaging!
    var mockRuntime: TestableExtensionRuntime!
    var mockNetworkService: MockNetworkService?

    // Mock constants
    let MOCK_ECID = "mock_ecid"
    let MOCK_EVENT_DATASET = "mock_event_dataset"
    let MOCK_EXP_ORG_ID = "mock_exp_org_id"
    let MOCK_PUSH_TOKEN = "mock_pushToken"

    // before each
    override func setUp() {
        mockRuntime = TestableExtensionRuntime()
        messaging = Messaging(runtime: mockRuntime)
        messaging.onRegistered()

        mockNetworkService = MockNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService!
    }

    /// validate the extension is registered without any error
    func testRegisterExtension_registersWithoutAnyErrorOrCrash() {
        XCTAssertNoThrow(MobileCore.registerExtensions([Messaging.self]))
    }

    /// validate that 3 listeners are registered onRegister
    func testOnRegistered_threeListenersAreRegistered() {
        XCTAssertEqual(mockRuntime.listeners.count, 2)
    }

    /// validating handleProcessEvent
    func testHandleProcessEvent_SetPushIdentifierEvent_Happy() {
        let eventData: [String: Any] = [MessagingConstants.EventDataKeys.PUSH_IDENTIFIER: MOCK_PUSH_TOKEN]
        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: eventData)
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: [:], status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: SampleEdgeIdentityState, status: SharedStateStatus.set))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))

        // verify that shared state is created
        XCTAssertEqual(MOCK_PUSH_TOKEN, mockRuntime.firstSharedState?[MessagingConstants.SharedState.Messaging.PUSH_IDENTIFIER] as! String)

        // verify the dispatched edge event
        guard let edgeEvent = mockRuntime.firstEvent else {
            XCTFail()
            return
        }
        XCTAssertEqual("Push notification profile edge event", edgeEvent.name)
        XCTAssertEqual(EventType.edge, edgeEvent.type)
        XCTAssertEqual(EventSource.requestContent, edgeEvent.source)

        // verify event data
        let flattenEdgeEvent = edgeEvent.data?.flattening()
        let pushNotification = flattenEdgeEvent?["data.pushNotificationDetails"] as? [[String: Any]]
        XCTAssertEqual(1, pushNotification?.count)
        let flattenedPushNotification = pushNotification?.first?.flattening()
        XCTAssertEqual("mock_ecid", flattenedPushNotification?["identity.id"] as? String)
        XCTAssertEqual(MOCK_PUSH_TOKEN, flattenedPushNotification?["token"] as? String)
        XCTAssertEqual(false, flattenedPushNotification?["denylisted"] as? Bool)
        XCTAssertNotNil(flattenedPushNotification?["appID"] as? String)
        XCTAssertEqual("ECID", flattenedPushNotification?["identity.namespace.code"] as? String)
        XCTAssertEqual("apns", flattenedPushNotification?["platform"] as? String)
    }

    /// validating handleProcessEvent withNilData
    func testHandleProcessEvent_withNilEventData() {
        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: nil)
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with no shared state
    func testHandleProcessEvent_NoSharedState() {
        let eventData: [String: Any] = [:]
        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: eventData)

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with empty shared state
    func testHandleProcessEvent_withEmptySharedState() {
        let eventData: [String: Any] = [:]
        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: eventData)
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: nil, status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: nil, status: SharedStateStatus.set))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with invalid config
    func testHandleProcessEvent_withInvalidConfig() {
        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: [:])
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: [:], status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: SampleEdgeIdentityState, status: SharedStateStatus.set))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with empty token
    func testHandleProcessEvent_withEmptyToken() {
        let mockConfig = [MessagingConstants.EventDataKeys.PUSH_IDENTIFIER: ""]

        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: [:])
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: mockConfig, status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: SampleEdgeIdentityState, status: SharedStateStatus.set))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with working shared state and data
    func testHandleProcessEvent_withNoIdentityData() {
        let mockConfig = [MessagingConstants.SharedState.Configuration.EXPERIENCE_CLOUD_ORG: MOCK_EXP_ORG_ID]

        let eventData: [String: Any] = [MessagingConstants.EventDataKeys.PUSH_IDENTIFIER: MOCK_PUSH_TOKEN]

        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: eventData)
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: mockConfig, status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: nil, status: SharedStateStatus.none))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with working shared state and data
    func testHandleProcessEvent_withConfigAndIdentityData() {
        let mockConfig = [MessagingConstants.SharedState.Configuration.EXPERIENCE_CLOUD_ORG: MOCK_EXP_ORG_ID]

        let eventData: [String: Any] = [MessagingConstants.EventDataKeys.PUSH_IDENTIFIER: MOCK_PUSH_TOKEN]

        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: eventData)
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: mockConfig, status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: SampleEdgeIdentityState, status: SharedStateStatus.set))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with working apns sandbox
    func testHandleProcessEvent_withApnsSandbox() {
        let mockConfig = [MessagingConstants.SharedState.Configuration.EXPERIENCE_CLOUD_ORG: MOCK_EXP_ORG_ID,
                          MessagingConstants.SharedState.Configuration.USE_SANDBOX: true] as [String: Any]

        let eventData: [String: Any] = [MessagingConstants.EventDataKeys.PUSH_IDENTIFIER: MOCK_PUSH_TOKEN]

        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: eventData)
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: mockConfig, status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: SampleEdgeIdentityState, status: SharedStateStatus.set))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with working apns sandbox
    func testHandleProcessEvent_withApns() {
        let mockConfig = [MessagingConstants.SharedState.Configuration.EXPERIENCE_CLOUD_ORG: MOCK_EXP_ORG_ID,
                          MessagingConstants.SharedState.Configuration.USE_SANDBOX: false] as [String: Any]

        let eventData: [String: Any] = [MessagingConstants.EventDataKeys.PUSH_IDENTIFIER: MOCK_PUSH_TOKEN]

        let event = Event(name: "handleProcessEvent", type: EventType.genericIdentity, source: EventSource.requestContent, data: eventData)
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: mockConfig, status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: SampleEdgeIdentityState, status: SharedStateStatus.set))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    /// validating handleProcessEvent with Tracking info event when event data is empty
    func testHandleProcessEvent_withTrackingInfoEvent() {
        let mockConfig = [MessagingConstants.SharedState.Configuration.EXPERIENCE_EVENT_DATASET: MOCK_EVENT_DATASET] as [String: Any]

        let eventData: [String: Any]? = ["key": "value"]

        let event = Event(name: "trackingInfo", type: MessagingConstants.EventType.messaging, source: EventSource.requestContent, data: eventData)
        mockRuntime.simulateSharedState(for: MessagingConstants.SharedState.Configuration.NAME, data: (value: mockConfig, status: SharedStateStatus.set))
        mockRuntime.simulateXDMSharedState(for: MessagingConstants.SharedState.EdgeIdentity.NAME, data: (value: SampleEdgeIdentityState, status: SharedStateStatus.set))

        // test
        XCTAssertNoThrow(messaging.handleProcessEvent(event))
    }

    // MARK: Private methods

    private var SampleEdgeIdentityState: [String: Any] {
        return [MessagingConstants.SharedState.EdgeIdentity.IDENTITY_MAP: [MessagingConstants.SharedState.EdgeIdentity.ECID: [[MessagingConstants.SharedState.EdgeIdentity.ID: MOCK_ECID]]]]
    }
}
