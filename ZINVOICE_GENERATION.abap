*&---------------------------------------------------------------------*
*& Report ZINVOICE_GENERATION
*&---------------------------------------------------------------------*
*& Simple Invoice Generation Report with Smartform + Simple PDF
*&---------------------------------------------------------------------*

REPORT zinvoice_generation.

* Parameters (make sure names are <=8 characters)
PARAMETERS: pname TYPE zinvoice_bk-customer_name,   " Customer Name
            pitem TYPE zinvoice_bk-item,             " Item
            pamnt TYPE zinvoice_bk-amount,           " Amount
            pcuky TYPE zinvoice_bk-cuky_field.       " Currency Key

* Data Declarations
DATA: lv_invid        TYPE zinvoice_bk-invoice_id,
      lv_fmnam        TYPE rs38l_fnam,
      lv_text_string  TYPE string,
      lt_pdf          TYPE solix_tab,
      lv_pdf_xstring  TYPE xstring,
      lv_filesize     TYPE i,
      lv_filename     TYPE string,
      lt_pdf_data     TYPE solix_tab,
      lv_bin_filesize TYPE i.

DATA: lv_cname TYPE zinvoice_bk-customer_name,
      lv_item  TYPE zinvoice_bk-item,
      lv_amnt  TYPE zinvoice_bk-amount,
      lv_cuky  TYPE zinvoice_bk-cuky_field,
      lv_invdt TYPE zinvoice_bk-invoice_date,
      lv_stat  TYPE zinvoice_bk-status.

DATA: wa_invoice TYPE zinvoice_bk,
      it_invoice TYPE STANDARD TABLE OF zinvoice_bk.

DATA: lv_amnt_str TYPE c LENGTH 20,
      lv_date_str TYPE c LENGTH 10.



START-OF-SELECTION.

  " Step 1: Generate Invoice ID
  lv_invid = |INV{ sy-datum }{ sy-uzeit }|.

  " Step 2: Prepare work area
  wa_invoice-invoice_id    = lv_invid.
  wa_invoice-customer_name = pname.
  wa_invoice-item          = pitem.
  wa_invoice-cuky_field    = pcuky.
  wa_invoice-amount        = pamnt.
  wa_invoice-invoice_date  = sy-datum.
  wa_invoice-status        = 'OPEN'.

  " Step 3: Append to internal table
  APPEND wa_invoice TO it_invoice.

  " Step 4: Insert internal table into database
  INSERT zinvoice_bk FROM TABLE @it_invoice.

  " Step 5: Check insert success
  IF sy-subrc = 0.

    WRITE: / 'Invoice created successfully. Invoice ID:', lv_invid.

     "-----------------------------------------------------------------
     "SMARTFORM INVOICE GENERATION
     "-----------------------------------------------------------------

     "Step 6: Get Smartform Function Module name
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname = 'ZINVOICE_FORM'   " Your smartform name
      IMPORTING
        fm_name  = lv_fmnam
      EXCEPTIONS
        OTHERS   = 1.

    IF sy-subrc = 0.

       "Step 7: Call the Smartform (It will open Print Preview)
      CALL FUNCTION lv_fmnam
        EXPORTING
          custname = pname
          item     = pitem
          amount   = pamnt
          cuky     = pcuky
          invdate  = sy-datum
          invid    = lv_invid
        EXCEPTIONS
          OTHERS   = 1.

      IF sy-subrc <> 0.
        WRITE: / 'Error calling Smartform.'.
      ENDIF.

    ELSE.
      WRITE: / 'Error: Unable to get Smartform function module.'.
    ENDIF.

    " -----------------------------------------------------------------
    " SIMPLE TEXT PDF GENERATION WITHOUT SMARTFORM
    " -----------------------------------------------------------------

    " Step 8: Prepare values for simple PDF
*    lv_cname = pname.
*    lv_item  = pitem.
*    lv_amnt  = pamnt.
*    lv_cuky  = pcuky.
*    lv_invdt = sy-datum.
*    lv_stat  = 'OPEN'.
*
*
*
*    " Convert numeric and date fields to string
*    WRITE lv_amnt TO lv_amnt_str.
*    WRITE lv_invdt TO lv_date_str.
*    " Step 9: Prepare Text for PDF
*    CONCATENATE
*      'Invoice ID:' lv_invid cl_abap_char_utilities=>newline
*      'Customer Name:' lv_cname cl_abap_char_utilities=>newline
*      'Item:' lv_item cl_abap_char_utilities=>newline
*      'Amount:' lv_amnt_str lv_cuky cl_abap_char_utilities=>newline
*      'Invoice Date:' lv_invdt cl_abap_char_utilities=>newline
*      'Status:' lv_stat cl_abap_char_utilities=>newline
*    INTO lv_text_string
*    SEPARATED BY space.
*
*
*    " Convert XSTRING to binary SOLIX table
*    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*      EXPORTING
*        buffer     = lv_pdf_xstring
*      IMPORTING
*        length     = lv_filesize
*      TABLES
*        binary_tab = lt_pdf_data.
*
*    IF sy-subrc = 0.
*
*      " Step 11: Download PDF
*      lv_filename = |Invoice_{ sy-datum+0(8) }_{ lv_invid }.pdf|.
*
*      CALL METHOD cl_gui_frontend_services=>gui_download
*        EXPORTING
*          bin_filesize = lv_filesize
*          filename     = lv_filename
*          filetype     = 'BIN'
*        CHANGING
*          data_tab     = lt_pdf_data
*        EXCEPTIONS
*          OTHERS       = 1.
*
*      IF sy-subrc = 0.
*        WRITE: / 'Simple PDF Invoice downloaded successfully:', lv_filename.
*      ELSE.
*        WRITE: / 'Error downloading the simple PDF.'.
*      ENDIF.
*
*    ELSE.
*      WRITE: / 'Error generating simple PDF content.'.
*    ENDIF.

else.
  write: / 'Invoice creation failed.'.
endif.
