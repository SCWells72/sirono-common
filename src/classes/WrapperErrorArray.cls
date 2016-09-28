/*
* @author Sirono
* @version 1.0.1
* @Date: 09-20-2016
* @description
* Viraj Rana: Public class to parse the error response.
* 
*/
Public class WrapperErrorArray {
    public class Errors {
        public String non_field_errors;
    }

    public String kind;
    public List<Errors> errors;
}