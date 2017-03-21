
public class WrapperErrorArray extends WrapperBadResponse {
    public class Errors {
        public String non_field_errors;
    }

    public String kind;
    public List<Errors> errors;

    public override List<String> getErrors() {
        List<String> errs = new String[]{};
        for(Errors nonFieldError: errors) {
            errs.add(String.format(WrapperBadResponse.LONG_ERROR, new String[]{kind, WrapperBadResponse.NON_FIELD_ERRORS_STR, nonFieldError.non_field_errors}));
        }
        return errs;
    }
}
