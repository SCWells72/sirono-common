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

/**
 * A wrapper class for logging messages. The formatting and destination of the messages will depend on the
 * the configuration of the <code>LoggerAdapter</code>.
 * <p/>
 * Sample usage:
 * <p/>
 * <pre>
 *     private static final Logger LOG = Logger.getInstance(MyClass.class);
 *     ...
 *     LOG.debug('Hello {0}! This logging stuff is {1}.', 'handsome', 'the bomb');
 * </pre>
 * <p/>
 * A couple of notes on how to work around some Apex quirks:
 * <ul>
 *     <li>
 *         When you use the logger in subclasses whose superclass also has a logger, you'll need to qualify
 *         each reference within the subclass. For example: <code>SubClass.LOG.debug()</code>.
 *     </li>
 *     <li>
 *         You can't declare static attributes in inner classes. In that case, either consider moving the inner class
 *         to be a standalone class, or use the containing class's logger (using a qualified reference:
 *         <code>ContainingClass.LOG.debug()</code>).
 *     </li>
 * </ul>
 * Note that the conflicts these cause are only identified when you run a build (or a metadata refresh) and they
 * will not get flagged if you just use <b>Ctrl+S</b>/<b>Cmd+S</b> within your IDE.
 */
public with sharing class Logger {
    // Once we come up with version of logging that doesn't just use System.debug(), we can make this value configurable
    // via a custom setting. For now it's just convenient to be able to set it for tests.
    @TestVisible
    private static LoggerAdapter LOGGER_ADAPTER = new DefaultLoggerAdapter();

    private final Type apexClass;

    private Logger(Type apexClass) {
        this.apexClass = apexClass;
    }

    public static Logger getInstance(Type apexClass) {
        return new Logger(apexClass);
    }

    public void debug(String msg) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg, null);
    }

    public void debug(String msg, Object param0) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg, new Object[] { param0 });
    }

    public void debug(String msg, Object param0, Object param1) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg, new Object[] { param0, param1 });
    }

    public void debug(String msg, Object param0, Object param1, Object param2) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg, new Object[] { param0, param1, param2 });
    }

    public void debug(String msg, Object param0, Object param1, Object param2, Object param3) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg, new Object[] { param0, param1, param2, param3 });
    }

    public void debug(String msg, Object param0, Object param1, Object param2, Object param3, Object param4) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg, new Object[] { param0, param1, param2, param3, param4 });
    }

    public void debug(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg, new Object[] { param0, param1, param2, param3, param4, param5 });
    }

    public void debug(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6 });
    }

    public void debug(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7 });
    }

    public void debug(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7, Object param8) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7, param8 });
    }

    public void debug(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7, Object param8, Object param9) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7, param8, param9 });
    }

    public void debug(String msg, Object[] params) {
        LOGGER_ADAPTER.log(LoggingLevel.DEBUG, apexClass, msg, params);
    }

    public void info(String msg) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg, null);
    }

    public void info(String msg, Object param0) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg, new Object[] { param0 });
    }

    public void info(String msg, Object param0, Object param1) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg, new Object[] { param0, param1 });
    }

    public void info(String msg, Object param0, Object param1, Object param2) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg, new Object[] { param0, param1, param2 });
    }

    public void info(String msg, Object param0, Object param1, Object param2, Object param3) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg, new Object[] { param0, param1, param2, param3 });
    }

    public void info(String msg, Object param0, Object param1, Object param2, Object param3, Object param4) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg, new Object[] { param0, param1, param2, param3, param4 });
    }

    public void info(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg, new Object[] { param0, param1, param2, param3, param4, param5 });
    }

    public void info(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6 });
    }

    public void info(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7 });
    }

    public void info(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7, Object param8) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7, param8 });
    }

    public void info(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7, Object param8, Object param9) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7, param8, param9 });
    }

    public void info(String msg, Object[] params) {
        LOGGER_ADAPTER.log(LoggingLevel.INFO, apexClass, msg, params);
    }

    public void warn(String msg) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg, null);
    }

    public void warn(String msg, Object param0) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg, new Object[] { param0 });
    }

    public void warn(String msg, Object param0, Object param1) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg, new Object[] { param0, param1 });
    }

    public void warn(String msg, Object param0, Object param1, Object param2) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg, new Object[] { param0, param1, param2 });
    }

    public void warn(String msg, Object param0, Object param1, Object param2, Object param3) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg, new Object[] { param0, param1, param2, param3 });
    }

    public void warn(String msg, Object param0, Object param1, Object param2, Object param3, Object param4) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg, new Object[] { param0, param1, param2, param3, param4 });
    }

    public void warn(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg, new Object[] { param0, param1, param2, param3, param4, param5 });
    }

    public void warn(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6 });
    }

    public void warn(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7 });
    }

    public void warn(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7, Object param8) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7, param8 });
    }

    public void warn(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7, Object param8, Object param9) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7, param8, param9 });
    }

    public void warn(String msg, Object[] params) {
        LOGGER_ADAPTER.log(LoggingLevel.WARN, apexClass, msg, params);
    }

    public void error(String msg) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg, null);
    }

    public void error(Exception ex) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, '\n{0} \n{1}', new Object[] { ex, ex.getStackTraceString() });
    }

    public void error(String msg, Object param0) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg, new Object[] { param0 });
    }

    public void error(String msg, Object param0, Object param1) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg, new Object[] { param0, param1 });
    }

    public void error(String msg, Object param0, Object param1, Object param2) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg, new Object[] { param0, param1, param2 });
    }

    public void error(String msg, Object param0, Object param1, Object param2, Object param3) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg, new Object[] { param0, param1, param2, param3 });
    }

    public void error(String msg, Object param0, Object param1, Object param2, Object param3, Object param4) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg, new Object[] { param0, param1, param2, param3, param4 });
    }

    public void error(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg, new Object[] { param0, param1, param2, param3, param4, param5 });
    }

    public void error(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6 });
    }

    public void error(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7 });
    }

    public void error(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7, Object param8) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7, param8 });
    }

    public void error(String msg, Object param0, Object param1, Object param2, Object param3, Object param4, Object param5,
        Object param6, Object param7, Object param8, Object param9) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg,
            new Object[] { param0, param1, param2, param3, param4, param5, param6, param7, param8, param9 });
    }

    public void error(String msg, Object[] params) {
        LOGGER_ADAPTER.log(LoggingLevel.ERROR, apexClass, msg, params);
    }

    /**
     * Implementations of this class will define how to format and output log messages.
     */
    public interface LoggerAdapter {
        /**
         * Defines how a message will be formatted and to where it will be output.
         *
         * @param logLevel The log level.
         * @param apexClass The class from which the message originated.
         * @param msg The message being logged.
         * @param params The parameters supplied for the log message.
         */
        void log(LoggingLevel logLevel, Type apexClass, String msg, Object[] params);
    }

    public abstract class AbstractLoggerAdapter implements LoggerAdapter {
        public void log(LoggingLevel level, Type apexClass, String msg, Object[] params) {
            try {
                if (CollectionUtil.isEmpty(params)) {
                    writeToLog(level, apexClass, msg);
                } else {
                    String[] stringParams = new String[] {};
                    for (Object obj : params) {
                        stringParams.add(String.valueOf(obj));
                    }
                    writeToLog(level, apexClass, String.format(msg, stringParams));
                }
            } catch (Exception e) {
                // catch any exception that gets thrown attempting to write the log message.
                handleException(level, apexClass, msg, params, e);
            }
        }

        /**
         * Implementations of this method will describe how a log message is formatted and where it is output.
         *
         * @param level The log level of the message.
         * @param apexClass The class from which the message originated.
         * @param msg The formatted message being logged.
         */
        protected abstract void writeToLog(LoggingLevel level, Type apexClass, String msg);

        /**
         * Implementations of this method will supply logic for how we handle an exception that is thrown while
         * attempting to write the log message.
         *
         * @param level The log level of the message.
         * @param apexClass The class from which the message originated.
         * @param msg The raw unformatted message being logged.
         * @param params The parameters supplied for the log message.
         * @param e The exception that was thrown.
         */
        protected virtual void handleException(LoggingLevel level, Type apexClass, String msg, Object[] params, Exception e) {
            // By default, just log a message using System.debug() and swallow the exception.
            String errorMessage = 'Exception thrown while attempting to write log message: ' +
                '\nlevel=' + level +
                '\nclass=' + apexClass +
                '\nmessage=' + msg +
                '\nparameters=' + params +
                '\nstackTrace=' + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, errorMessage);
        }
    }

    /**
     * Implementation of LoggerAdapter that directs all logging through the built-in Apex method <code>System.debug()</code>
     */
    public class DefaultLoggerAdapter extends AbstractLoggerAdapter {
        private String FORMAT_STRING = '{0}: {1}';

        protected override void writeToLog(LoggingLevel level, Type apexClass, String msg) {
            System.debug(level, String.format(FORMAT_STRING, new String[] { apexClass.getName(), msg }));
        }
    }
}