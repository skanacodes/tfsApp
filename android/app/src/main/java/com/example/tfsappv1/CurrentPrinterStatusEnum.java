package com.example.tfsappv1;

/**
 * Created by Aly on 04/07/2017.
 */

public enum CurrentPrinterStatusEnum {

    PRINTER_STATUS_OK(0),
    PRINTER_STATUS_NO_PAPER(1),
    PRINTER_STATUS_NO_REACTION  (2),
    PRINTER_STATUS_GET_FAILE(3),
    PRINTER_STATUS_LOW_POWER(4);


    private int code;

    CurrentPrinterStatusEnum(int code) {
        this.code = code;
    }

    public int getCode() {
        return code;
    }

    public static CurrentPrinterStatusEnum fromCode(int code) {
        for (CurrentPrinterStatusEnum message : CurrentPrinterStatusEnum.values()) {
            if (message.getCode() == code) {
                return message;
            }
        }
        return PRINTER_STATUS_GET_FAILE;
    }
}
