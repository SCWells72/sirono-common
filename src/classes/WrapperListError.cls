/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Public class to parse the error response.
 */
public class WrapperListError extends WrapperBadResponse {
    public List<String> errors;
    public String kind;

    public override List<String> getErrors() {
        List<String> errs = new String[] {};
        for (String err : errors) {
            errs.add(String.format(WrapperBadResponse.SHORT_ERROR, new String[] { kind, err }));
        }
        return errs;
    }
}
