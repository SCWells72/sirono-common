/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/*
 * The only thing this does is delete the static resource after everything is loaded and we no longer need it.
 */

StaticResource staticResource = [
    SELECT Id
    FROM StaticResources
    WHERE Name = 'HIMSS_Estimate'
    LIMIT 1
];

delete staticResource;