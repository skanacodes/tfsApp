package com.example.tfsappv1;

/**
 * Created by Aly on 04/07/2017.
 */

public enum PrinterStatusEnum {

    PRINTER_STATUS_OK(0),
    PRINTER_STATUS_NO_PAPER(1),
    PRINTER_STATUS_OVER_HEAT(-1),
    PRINTER_STATUS_GET_FAILED(-2);


    private int code;

    PrinterStatusEnum(int code) {
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
