package com.example.tfsappv1;
/**
 * Created by Aly on 04/07/2017.
 */

public enum PaperStatusEnum {

    PRINTER_NO_PAPER(0),
    PRINTER_EXIST_PAPER(1),
    PRINTER_PAPER_ERROR(2);


    private int code;

    PaperStatusEnum(int code) {
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
