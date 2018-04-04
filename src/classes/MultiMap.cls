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
 * A multi-valued <code>Map</code>. Because of limitations in Apex (inability to extend the system <code>Map</code>
 * implementation, lack of custom parameterized types, etc.), extraction of values from a multi-map requires explicit
 * casting. <code>CollectionUtil</code> provides convenience methods for working with untyped key and value collections.
 *
 * @see Map
 * @see CollectionUtil
 */
public with sharing class MultiMap {

    // NOTE: These singletons should be declared in the respective classes but Apex doesn't currently allow static inner classes
    // and therefore doesn't allow static members of inner classes.
    private static final ListCollectionAdapterFactory LIST_COLLECTION_ADAPTER_FACTORY = new ListCollectionAdapterFactory();
    private static final SetCollectionAdapterFactory SET_COLLECTION_ADAPTER_FACTORY = new SetCollectionAdapterFactory();

    private final Map<Object, CollectionAdapter> storage = new Map<Object, CollectionAdapter>();
    private final CollectionAdapterFactory collectionAdapterFactory;

    /**
     * Creates a new multi-map with <code>List</code>-based storage of values. Duplicate values are allowed and
     * insertion order is retained.
     *
     * @return a new list-based multi-map
     * 
     * @see List
     */
    public static MultiMap newListInstance() {
        return new MultiMap(LIST_COLLECTION_ADAPTER_FACTORY);
    }

    /**
     * Creates a new multi-map with <code>Set</code>-based storage of values. Duplicate values are not allowed and 
     * insertion order is not retained.
     *
     * @return a new set-based multi-map
     * 
     * @see Set
     */
    public static MultiMap newSetInstance() {
        return new MultiMap(SET_COLLECTION_ADAPTER_FACTORY);
    }

    private MultiMap(CollectionAdapterFactory collectionAdapterFactory) {
        this.collectionAdapterFactory = collectionAdapterFactory;
    }

    private CollectionAdapter getCollectionAdapter(Object key) {
        CollectionAdapter collectionAdapter = storage.get(key);
        if (collectionAdapter == null) {
            collectionAdapter = collectionAdapterFactory.createCollectionAdapter();
            storage.put(key, collectionAdapter);
        }
        return collectionAdapter;
    }

    /**
     * Returns whether or not the multi-map contains values for the specified key.
     *
     * @param key the key
     *
     * @return <code>true</code> if the multi-map contains values for the specified key; otherwise <code>false</code>
     */
    public Boolean containsKey(Object key) {
        CollectionAdapter collectionAdapter = getCollectionAdapter(key);
        return !collectionAdapter.isEmpty();
    }

    /**
     * Adds a single value to the multi-map for the specified key.
     *
     * @param key the key
     * @param value the value
     */
    public void putValue(Object key, Object value) {
        CollectionAdapter collectionAdapter = getCollectionAdapter(key);
        collectionAdapter.add(value);
    }

    /**
     * Adds multiple values to the multi-map for the specified key.
     *
     * @param key the key
     * @param values the values
     */
    public void putValues(Object key, List<Object> values) {
        CollectionAdapter collectionAdapter = getCollectionAdapter(key);
        collectionAdapter.addAll(values);
    }

    /**
     * Adds multiple values to the multi-map for the specified key.
     *
     * @param key the key
     * @param values the values
     */
    public void putValues(Object key, Set<Object> values) {
        CollectionAdapter collectionAdapter = getCollectionAdapter(key);
        collectionAdapter.addAll(values);
    }

    /**
     * Adds all values from the provided source multi-map to this one.
     *
     * @param source the source multi-map
     */
    public void putAllValues(MultiMap source) {
        Set<Object> keys = source.keySet();
        for (Object key : keys) {
            List<Object> values = source.getValues(key);
            putValues(key, values);
        }
    }

    /**
     * Returns all values for the specified key. Note that a non-null list is returned even if no values have
     * ever been added for the specified key.
     *
     * @param key the key for which values are requested
     *
     * @return a list of values for the specified key
     */
    public List<Object> getValues(Object key) {
        CollectionAdapter collectionAdapter = getCollectionAdapter(key);
        return collectionAdapter.toList();
    }

    /**
     * Returns all distinct values for the specified key. Note that a non-null set is returned even if no values have
     * ever been added for the specified key.
     *
     * @param key the key for which values are requested
     *
     * @return a set of distinct values for the specified key
     */
    public Set<Object> getValueSet(Object key) {
        CollectionAdapter collectionAdapter = getCollectionAdapter(key);
        return collectionAdapter.toSet();
    }

    /**
     * Removes all values for the specified key.
     *
     * @param key the key for which all values should be removed
     *
     * @return <code>true</code> if the key had values which were removed; otherwise <code>false</code>
     */
    public Boolean remove(Object key) {
        CollectionAdapter collectionAdapter = getCollectionAdapter(key);
        Boolean result = !collectionAdapter.isEmpty();
        storage.remove(key);
        return result;
    }

    /**
     * Removes a single value for the specified key.
     *
     * @param key the key for which the value should be removed
     * @param value the value which should be removed
     *
     * @return the value which was removed
     */
    public Object removeValue(Object key, Object value) {
        CollectionAdapter collectionAdapter = getCollectionAdapter(key);
        return collectionAdapter.remove(value);
    }

    /**
     * Removes all contents from the multi-map.
     */
    public void clear() {
        storage.clear();
    }

    /**
     * Returns all keys from the multi-map.
     *
     * @return the set of all keys
     */
    public Set<Object> keySet() {
        Set<Object> keySet = new Set<Object>();
        for (Object key : storage.keySet()) {
            CollectionAdapter collectionAdapter = getCollectionAdapter(key);
            if (!collectionAdapter.isEmpty()) {
                keySet.add(key);
            }
        }

        return keySet;
    }

    /**
     * Returns all values from the multi-map.
     *
     * @return the list of all values
     */
    public List<Object> values() {
        List<Object> allValues = new List<Object>();
        for (CollectionAdapter collectionAdapter : storage.values()) {
            allValues.addAll(collectionAdapter.toList());
        }
        return allValues;
    }

    /**
     * Returns whether or not the multi-map has contents.
     *
     * @return <code>true</code> if the multi-map is empty; otherwise <code>false</code>
     */
    public Boolean isEmpty() {
        for (CollectionAdapter collectionAdapter : storage.values()) {
            if (!collectionAdapter.isEmpty()) {
                return false;
            }
        }
        return true;
    }

    /**
     * Returns the total number of entries (not values) in the multimap
     *
     * @return the number of entries in the map
     */
    public Integer size() {
        return storage.size();
    }

    // Collection adapters

    /**
     * Interface for factories to creates collection adapters of the correct type.
     */
    private interface CollectionAdapterFactory {
        /**
         * Creates a new collection adapter.
         *
         * @return the created collection adapter
         */
        CollectionAdapter createCollectionAdapter();
    }

    /**
     * Provides indirect access to collections since Apex doesn't include a common <code>Collection</code> interface
     * for both <code>List</code> and <code>Set</code>. Concrete implementations should adapt the interface methods
     * as appropriate for the underlying actual storage mechanism.
     */
    private interface CollectionAdapter {
        /**
         * Returns whether or not the collection has contents.
         *
         * @return <code>true</code> if the collection is empty; otherwise <code>false</code>
         */
        Boolean isEmpty();

        /**
         * Adds the specified object to the collection and returns it.
         *
         * @param value the object to be added
         *
         * @return the stored object
         */
        Object add(Object value);

        /**
         * Adds all of the provided objects to the collection.
         *
         * @param values the objects to be added
         */
        void addAll(List<Object> values);

        /**
         * Adds all of the provided objects to the collection.
         *
         * @param values the objects to be added
         */
        void addAll(Set<Object> values);

        /**
         * Removes the specified object from the collection and returns it.
         *
         * @param value the object to be removed
         *
         * @return the removed object, or <code>null</code> if the specified object was not in the collection
         */
        Object remove(Object value);

        /**
         * Returns all values in the collection as a <code>List</code>.
         *
         * @return the list of all stored values
         */
        List<Object> toList();

        /**
         * Returns all distinct values in the collection as a <code>Set</code>.
         *
         * @return the set of all stored values
         */
        Set<Object> toSet();
    }

    /**
     * A concrete implementation of <code>CollectionAdapterFactory</code> for <code>List</code>-based collections.
     */
    private class ListCollectionAdapterFactory implements CollectionAdapterFactory {
        public CollectionAdapter createCollectionAdapter() {
            return new ListCollectionAdapter();
        }
    }

    /**
     * A concrete implementation of <code>CollectionAdapter</code> for <code>List</code>-based collections.
     */
    private class ListCollectionAdapter implements CollectionAdapter {
        private List<Object> delegate = new List<Object>();

        public Boolean isEmpty() {
            return delegate.isEmpty();
        }

        public Object add(Object value) {
            return delegate.add(value);
        }

        public void addAll(List<Object> values) {
            delegate.addAll(values);
        }

        public void addAll(Set<Object> values) {
            delegate.addAll(values);
        }

        public Object remove(Object value) {
            for (Integer i = 0, numValues = delegate.size(); i < numValues; i++) {
                Object currentValue = delegate.get(i);
                if (((value != null) && (currentValue != null) && value.equals(currentValue)) || (value == currentValue)) {
                    return delegate.remove(i);
                }
            }

            return null;
        }

        public List<Object> toList() {
            return delegate;
        }

        public Set<Object> toSet() {
            Set<Object> distinctValues = new Set<Object>();
            distinctValues.addAll(delegate);
            return distinctValues;
        }
    }

    /**
     * A concrete implementation of <code>CollectionAdapterFactory</code> for <code>Set</code>-based collections.
     */
    private class SetCollectionAdapterFactory implements CollectionAdapterFactory {
        public CollectionAdapter createCollectionAdapter() {
            return new SetCollectionAdapter();
        }
    }

    /**
     * A concrete implementation of <code>CollectionAdapter</code> for <code>Set</code>-based collections.
     */
    private class SetCollectionAdapter implements CollectionAdapter {
        private Set<Object> delegate = new Set<Object>();

        public Boolean isEmpty() {
            return delegate.isEmpty();
        }

        public Object add(Object value) {
            return delegate.add(value);
        }

        public void addAll(List<Object> values) {
            delegate.addAll(values);
        }

        public void addAll(Set<Object> values) {
            delegate.addAll(values);
        }

        public Object remove(Object value) {
            if (delegate.remove(value)) {
                return value;
            } else {
                return null;
            }
        }

        public List<Object> toList() {
            List<Object> listStorage = new List<Object>();
            listStorage.addAll(delegate);
            return listStorage;
        }

        public Set<Object> toSet() {
            return delegate;
        }
    }
}