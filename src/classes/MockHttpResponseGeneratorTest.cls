/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-06-2016
 * Viraj: Dummy class for the call out.
 * 10-17-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF - Call out with fake response
 * 10-17-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF - Call out with fake response
 */

@isTest
global class MockHttpResponseGeneratorTest implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('/paymentplan')) {
            //res.setBody(TestUtility.responseBody);
            res.setBody(PaymentPlanJSONParsing.testResponse());
        } else if (req.getEndpoint().contains('api/chargegroups')) {
            res.setBody(ChargeGroupJSONParsing.testParse());
        }else if (req.getEndpoint().contains('api/adjustments')) {
            if (req.getEndpoint().contains('/transactions/')) {
                res.setBody(TransactionJSONParsing.testResponse());
        } else {
                res.setBody(PaymentAdjustmentJSONParsing.testResponse());
            }            
        }else if (req.getEndpoint().contains('api/paychargegroups')) {
            if (req.getEndpoint().contains('/transactions/')) {
                res.setBody(TransactionJSONParsing.testResponse());
            } else{
                res.setBody(PaymentJSONParsing.testResponse());
            }            
        }else{
            res.setBody(TestUtility.body);
        }

        if (req.getMethod() == 'DELETE') {
            res.setStatusCode(204);
        } else {
            res.setStatusCode(TestUtility.statusCode);
        }

        res.setStatus(TestUtility.status);

        return res;
    }
}