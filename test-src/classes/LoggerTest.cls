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
public with sharing class LoggerTest {
    private static final List<LoggingLevel> LEVELS_TO_TEST = new LoggingLevel[] {
        LoggingLevel.DEBUG,
        LoggingLevel.INFO,
        LoggingLevel.WARN,
        LoggingLevel.ERROR
    };

    @IsTest
    private static void testAbstractLoggerAdapterWithDifferentLogLevels() {
        // We just want to make sure we can invoke this adapter with a variety of inputs to make verify
        // that exceptions aren't thrown. It's always the worst when you break your code trying to log stuff.
        TestLoggerAdapter loggerAdapter = new TestLoggerAdapter();

        // test simple case (no params) for each log level
        String testMessage = 'message';
        for (LoggingLevel level : LEVELS_TO_TEST) {
            loggerAdapter.log(level, Assert.class, testMessage, null);
            Assert.equals(level, loggerAdapter.lastLogLevel);
            Assert.equals(testMessage, loggerAdapter.lastLogMsg);
            Assert.equals(Assert.class.getName(), loggerAdapter.lastClass);
        }
    }

    @IsTest
    private static void testDefaultLoggerAdapter() {
        // We just want to make sure we can invoke this adapter with a variety of inputs to make verify
        // that exceptions aren't thrown. It's always the worst when you break your code trying to log stuff.
        TestLoggerAdapter loggerAdapter = new TestLoggerAdapter();

        for (LoggingLevel level : LEVELS_TO_TEST) {
            String msg = 'msg: {0}.';
            loggerAdapter.log(level, Assert.class, msg, null);

            // attempt to log with different numbers of parameters. Note that the behavior of String.format() is such
            // that if no values are specified for a placeholder, the placeholder is just left in place unchanged.
            loggerAdapter.log(level, Assert.class, msg, new Object[] {});
            Assert.equals(msg, loggerAdapter.lastLogMsg);

            loggerAdapter.log(level, Assert.class, msg, new Object[] { 'param0' });
            Assert.equals('msg: param0.', loggerAdapter.lastLogMsg);

            loggerAdapter.log(level, Assert.class, msg, new Object[] { 'param0', 'param1' });
            Assert.equals('msg: param0.', loggerAdapter.lastLogMsg);

            loggerAdapter.log(level, Assert.class, msg, new Object[] { 'param0', 'param1', 'param2'});
            Assert.equals('msg: param0.', loggerAdapter.lastLogMsg);

            // attempt to log with different types of parameters.
            loggerAdapter.log(level, Assert.class, msg, new Object[] { null });
            Assert.equals('msg: null.', loggerAdapter.lastLogMsg);

            loggerAdapter.log(level, Assert.class, msg, new Object[] { 1 });
            Assert.equals('msg: 1.', loggerAdapter.lastLogMsg);

            loggerAdapter.log(level, Assert.class, msg, new Object[] { 3.14159 });
            Assert.equals('msg: 3.14159.', loggerAdapter.lastLogMsg);

            Contact testObj = new Contact(LastName = 'lastName');
            loggerAdapter.log(level, Assert.class, msg, new Object[] { testObj });
            Assert.equals('msg: ' + String.valueOf(testObj) + '.', loggerAdapter.lastLogMsg);
        }
    }

    @IsTest
    private static void testDebugMethods() {
        // Verify that all of the log.debug() variations work as expected.

        // Note that the behavior of String.format() is such that if no values are specified for a placeholder,
        // the placeholder is just left in place unchanged.
        String formatString = '{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}';

        TestLoggerAdapter loggerAdapter = new TestLoggerAdapter();
        Logger.LOGGER_ADAPTER = loggerAdapter;

        Logger log = Logger.getInstance(Assert.class);

        log.debug(formatString);
        Assert.equals('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0');
        Assert.equals('param0,{1},{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1');
        Assert.equals('param0,param1,{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1', 'param2');
        Assert.equals('param0,param1,param2,{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1', 'param2', 'param3');
        Assert.equals('param0,param1,param2,param3,{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1', 'param2', 'param3', 'param4');
        Assert.equals('param0,param1,param2,param3,param4,{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5');
        Assert.equals('param0,param1,param2,param3,param4,param5,{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7', 'param8');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,param8,{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);

        log.debug(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7', 'param8', 'param9');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,param8,param9', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.DEBUG, loggerAdapter.lastLogLevel);
    }

    @IsTest
    private static void testInfoMethods() {
        // Verify that all of the Logger.info() variations work as expected.

        // Note that the behavior of String.format() is such that if no values are specified for a placeholder,
        // the placeholder is just left in place unchanged.
        String formatString = '{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}';

        TestLoggerAdapter loggerAdapter = new TestLoggerAdapter();
        Logger.LOGGER_ADAPTER = loggerAdapter;

        Logger log = Logger.getInstance(Assert.class);

        log.info(formatString);
        Assert.equals('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0');
        Assert.equals('param0,{1},{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1');
        Assert.equals('param0,param1,{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1', 'param2');
        Assert.equals('param0,param1,param2,{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1', 'param2', 'param3');
        Assert.equals('param0,param1,param2,param3,{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1', 'param2', 'param3', 'param4');
        Assert.equals('param0,param1,param2,param3,param4,{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5');
        Assert.equals('param0,param1,param2,param3,param4,param5,{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7', 'param8');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,param8,{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);

        log.info(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7', 'param8', 'param9');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,param8,param9', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.INFO, loggerAdapter.lastLogLevel);
    }

    @IsTest
    private static void testWarnMethods() {
        // Verify that all of the Logger.warn() variations work as expected.

        // Note that the behavior of String.format() is such that if no values are specified for a placeholder,
        // the placeholder is just left in place unchanged.
        String formatString = '{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}';

        TestLoggerAdapter loggerAdapter = new TestLoggerAdapter();
        Logger.LOGGER_ADAPTER = loggerAdapter;

        Logger log = Logger.getInstance(Assert.class);

        log.warn(formatString);
        Assert.equals('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0');
        Assert.equals('param0,{1},{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1');
        Assert.equals('param0,param1,{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1', 'param2');
        Assert.equals('param0,param1,param2,{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1', 'param2', 'param3');
        Assert.equals('param0,param1,param2,param3,{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1', 'param2', 'param3', 'param4');
        Assert.equals('param0,param1,param2,param3,param4,{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5');
        Assert.equals('param0,param1,param2,param3,param4,param5,{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7', 'param8');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,param8,{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);

        log.warn(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7', 'param8', 'param9');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,param8,param9', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.WARN, loggerAdapter.lastLogLevel);
    }

    @IsTest
    private static void testErrorMethods() {
        // Verify that all of the Logger.error() variations work as expected.

        // Note that the behavior of String.format() is such that if no values are specified for a placeholder,
        // the placeholder is just left in place unchanged.
        String formatString = '{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}';

        TestLoggerAdapter loggerAdapter = new TestLoggerAdapter();
        Logger.LOGGER_ADAPTER = loggerAdapter;

        Logger log = Logger.getInstance(Assert.class);

        log.error(formatString);
        Assert.equals('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0');
        Assert.equals('param0,{1},{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1');
        Assert.equals('param0,param1,{2},{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1', 'param2');
        Assert.equals('param0,param1,param2,{3},{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1', 'param2', 'param3');
        Assert.equals('param0,param1,param2,param3,{4},{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1', 'param2', 'param3', 'param4');
        Assert.equals('param0,param1,param2,param3,param4,{5},{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5');
        Assert.equals('param0,param1,param2,param3,param4,param5,{6},{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,{7},{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,{8},{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7', 'param8');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,param8,{9}', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);

        log.error(formatString, 'param0', 'param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7', 'param8', 'param9');
        Assert.equals('param0,param1,param2,param3,param4,param5,param6,param7,param8,param9', loggerAdapter.lastLogMsg);
        Assert.equals(LoggingLevel.ERROR, loggerAdapter.lastLogLevel);
    }

    @IsTest
    private static void testCatchExceptions() {
        // ensure that, when an exception is thrown while writing a log message, it is not propagated to the
        // containing logic.
        TestExceptionalLoggerAdapter loggerAdapter = new TestExceptionalLoggerAdapter();
        Logger.LOGGER_ADAPTER = loggerAdapter;

        Logger log = Logger.getInstance(Assert.class);
        Assert.isFalse(loggerAdapter.exceptionThrown);
        log.debug('test throwing an exception');
        Assert.isTrue(loggerAdapter.exceptionThrown);
    }

    public class TestLoggerAdapter extends Logger.AbstractLoggerAdapter {
        public LoggingLevel lastLogLevel;
        public String lastLogMsg;
        public String lastClass;

        protected override void writeToLog(LoggingLevel level, Type apexClass, String msg) {
            lastLogLevel = level;
            lastClass = apexClass.getName();
            lastLogMsg = msg;
        }
    }

    /**
     * Implementation of LoggerAdapter that will throw an exception each time it tries to log a message, and sets
     * a flag in the handleException() method to allow us to verify that it was invoked.
     */
    private class TestExceptionalLoggerAdapter extends Logger.AbstractLoggerAdapter {
        public LoggingLevel lastLogLevel;
        public String lastLogMsg;
        public String lastClass;
        public Boolean exceptionThrown = false;

        protected override void writeToLog(LoggingLevel level, Type apexClass, String msg) {
            lastLogLevel = level;
            lastClass = apexClass.getName();
            lastLogMsg = msg;
            exceptionThrown = false;
            throw new IllegalStateException('Wrong!');
        }

        protected override void handleException(LoggingLevel level, Type apexClass, String msg, Object[] params, Exception e) {
            exceptionThrown = true;
            super.handleException(level, apexClass, msg, params, e);
        }
    }
}