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
 * An interface used to compare two values to one another for ordering purposes, in particular by
 * <code>CollectionUtil.sort()</code>.
 *
 * @see CollectionUtil
 */
public interface Comparator {
    /**
     * Returns value denoting the relationship between the two provided values.
     *
     * @param value1 the first value
     * @param value2 the second value
     *
     * @return a negative integer if <code>value1</code> should be ordered before <code>value2</code>; a positive
     * integer if <code>value1</code> should be ordered after <code>value2</code>; zero if the two values should be
     * considered equivalent for ordering purposes
     */
    Integer compare(Object value1, Object value2);
}