/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * JSON Parsing Class for the response which comes from Request. 
 */
Public class WrapperPaymentPlan {
    public String url;  //http://127.0.0.1:8000/paystaff/api/paymentplan/2876/
    public boolean active;
    public Decimal installment_amount;  //5000
    public Integer number_installments; //7
    public Decimal plan_value;  //32772
    public String plan_type;    //auto
    public Decimal payable_amount;  //32772
    public Integer execute_on_day;  //13
    public String guarantor;    //http://127.0.0.1:8000/paystaff/api/guarantors/141623/
    public String next_payment_date;    //2016-05-13
    public Integer installments_paid;   //0
    public Integer installments_total;  //7
    public boolean has_error;
    public String charges_added_since_start;
    public Date error_date;
    public boolean delinquent;
    public date delinquent_date ;
    public Integer authorized_amount;   //0
}