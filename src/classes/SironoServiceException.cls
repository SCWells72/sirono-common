/**
 * Exception that occurs when an error is encountered during a Service operation.
 */
public class SironoServiceException extends Exception {

    // A list of errors associated with the exception.
    public List<String> errors { set; get; }

    public SironoServiceException(List<String> errors) {
        this.errors = errors;
    }
}