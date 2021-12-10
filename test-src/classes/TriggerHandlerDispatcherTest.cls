/*
 * Copyright 2017-present Sirono LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@IsTest
private class TriggerHandlerDispatcherTest {
    private static final String STANDARD_PROFILE_NAME = 'Standard User';
    private static final String STANDARD_USER1_NAME = 'standard1@nowhere.com';
    private static final String STANDARD_USER2_NAME = 'standard2@nowhere.com';

    @TestSetup
    static void setup() {
        // Get a profile with standard permissions.
        Profile profile = [SELECT Id FROM Profile WHERE Name = :STANDARD_PROFILE_NAME LIMIT 1];

        // Create two users in that profile.
        List<User> standardUsers = new List<User>{
            new User(
                ProfileId = profile.Id,
                Username = STANDARD_USER1_NAME,
                Email = STANDARD_USER1_NAME,
                Alias = 'std1',
                FirstName = 'Standard1',
                LastName = 'User',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = UserInfo.getLocale(),
                LocaleSidKey = UserInfo.getLocale(),
                TimeZoneSidKey = UserInfo.getTimeZone().getID()
            ),
            new User(
                ProfileId = profile.Id,
                Username = STANDARD_USER2_NAME,
                Email = STANDARD_USER2_NAME,
                Alias = 'std2',
                FirstName = 'Standard2',
                LastName = 'User',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = UserInfo.getLocale(),
                LocaleSidKey = UserInfo.getLocale(),
                TimeZoneSidKey = UserInfo.getTimeZone().getID()
            )
        };
        insert standardUsers;

        // Create an opportunity as user 1.
        System.runAs(getUserByUsername(STANDARD_USER1_NAME)) {
            insert new Opportunity(Name = 'Test', StageName = [SELECT ApiName FROM OpportunityStage LIMIT 1].ApiName, CloseDate = Date.today());
        }
    }

    /**
     * Retrieves the <code>User</code> with the specified <code>Username</code>.
     *
     * @param username the <code>Username</code> of the <code>User</code> to retrieve
     *
     * @return the <code>User</code> with the specified <code>Username</code>
     */
    private static User getUserByUsername(String username) {
        return [SELECT Id FROM User WHERE Username = :username LIMIT 1];
    }

    /**
     * A <code>TriggerHandlerFactory</code> for testing a WITHOUT SHARING <code>TriggerHandler</code>.
     */
    public inherited sharing class WithSharingTriggerHandlerFactory implements TriggerHandlerFactory {
        public TriggerHandler create(List<SObject> objects, Map<Id, SObject> oldObjectsById) {
            return new WithSharingTriggerHandler();
        }
    }

    /**
     * A WITHOUT SHARING <code>TriggerHandler</code>, meaning the sharing rules are restricted to the
     * current <code>User</code>.
     */
    public with sharing class WithSharingTriggerHandler extends AbstractTriggerHandler {
        /**
         * Mocks the functionality of afterInsert() to retrieve <code>Opportunity</code> records that the
         * current <code>User</code> has sharing permission to access.
         * If it cannot find any, then it throws a <code>NoDataFoundException</code>.
         */
        public override void afterInsert() {
            List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
            if (CollectionUtil.isEmpty(opportunities)) {
                throw new NoDataFoundException();
            }
        }
    }

    @IsTest
    static void testWithSharingTriggerHandler() {
        // Mock the TriggerHandlerDispatcher to act as if it is processing an AFTER INSERT event.
        TriggerHandlerDispatcher.mock(TriggerOperation.AFTER_INSERT);

        // Run as Standard User 2, who does not have sharing permission to Standard User 1's Opportunity.
        System.runAs(getUserByUsername(STANDARD_USER2_NAME)) {
            try {
                // Use a WithoutSharingHelper since in a non-mocked trigger context, the trigger operates
                // WITHOUT SHARING.
                new WithoutSharingHelper().dispatch(WithSharingTriggerHandlerFactory.class);
                Assert.fail('Exception expected.');
            } catch (NoDataFoundException e) {
                // We expect a NoDataFoundException because Standard User 2 does not have sharing permission to
                // Standard User 1's Opportunity.
            }
        }
    }

    /**
     * A <code>TriggerHandlerFactory</code> for testing an INHERITED SHARING <code>TriggerHandler</code>.
     */
    public inherited sharing class InheritedSharingTriggerHandlerFactory implements TriggerHandlerFactory {
        public TriggerHandler create(List<SObject> objects, Map<Id, SObject> oldObjectsById) {
            return new InheritedSharingTriggerHandler();
        }
    }

    /**
     * An INHERITED SHARING <code>TriggerHandler</code>, meaning the sharing rules are derived from the context
     * that called it.  In a trigger context, it will be called by a trigger which operates WITHOUT SHARING and
     * passes those sharing permissions down.  If it were for some reason to be called by a controller which
     * should operate WITH SHARING, then those sharing permissions will apply.
     */
    public inherited sharing class InheritedSharingTriggerHandler extends AbstractTriggerHandler {
        public override void afterInsert() {
            List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
            if (CollectionUtil.isEmpty(opportunities)) {
                throw new NoDataFoundException();
            }
        }
    }

    @IsTest
    static void testInheritedSharingTriggerHandler() {
        // Mock the TriggerHandlerDispatcher to act as if it is processing an AFTER INSERT event.
        TriggerHandlerDispatcher.mock(TriggerOperation.AFTER_INSERT);

        // Run as Standard User 2, who does not have sharing permission to Standard User 1's Opportunity.
        System.runAs(getUserByUsername(STANDARD_USER2_NAME)) {
            try {
                // Use a WithoutSharingHelper since in a non-mocked trigger context, the trigger operates
                // WITHOUT SHARING.
                new WithoutSharingHelper().dispatch(InheritedSharingTriggerHandlerFactory.class);
            } catch (NoDataFoundException e) {
                // We expect no NoDataFoundException because the trigger handler operating with the inherited
                // WITHOUT SHARING permissions is allowed permission to Standard User 1's Opportunity despite the
                // fact that Standard User 2 does not have sharing permissions to it in the user context.
                Assert.fail('Exception not expected.');
            }
        }
    }

    /**
     * A helper class needed to emulate a trigger context which operated WITHOUT SHARING.
     */
    public without sharing class WithoutSharingHelper {
        /**
         * Dispatch the current trigger event to a trigger handler created using the specified factory.
         *
         * @param factoryType the class for the trigger handler factory used to create the trigger handler
         */
        public void dispatch(Type factoryType) {
            TriggerHandlerDispatcher.dispatch(factoryType);
        }
    }
}