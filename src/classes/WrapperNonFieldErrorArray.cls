/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public class WrapperNonFieldErrorArray extends WrapperBadResponse {

    public List<string> non_field_errors;

    public override List<String> getErrors() {
        List<String> errs = new String[]{};
        for(String err: non_field_errors) {
            errs.add(String.format(WrapperBadResponse.SHORT_ERROR, new String[]{WrapperBadResponse.NON_FIELD_ERRORS_STR, err}));
        }
        return errs;
    }
}
