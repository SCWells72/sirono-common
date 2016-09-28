/*
* @author Sirono
* @version 1.0.1
* @Date: 09-13-2016
* @description
* Viraj Rana: Public class to parse the error response.
* 
*/
Public class WrapperError {
    public class Errors {
        public List<String> non_field_errors;
    }
    public String kind;
    public Errors errors;
}