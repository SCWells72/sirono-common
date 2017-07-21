/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public class  WrapperError extends WrapperBadResponse {

    public class Errors {
        public List<String> non_field_errors;
    }
    public String kind;
    public Errors errors;

    public override List<String> getErrors() {
        List<String> errs = new String[]{};
        for(String err: Errors.non_field_errors) {
            errs.add(String.format(WrapperBadResponse.LONG_ERROR, new String[]{kind, WrapperBadResponse.NON_FIELD_ERRORS_STR, err}));
        }
        return errs;
    }
}
