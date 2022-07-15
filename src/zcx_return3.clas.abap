class ZCX_RETURN3 definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  aliases MSGTY
    for IF_T100_DYN_MSG~MSGTY .

  types:
    gtt_bapireturn_t TYPE STANDARD TABLE OF bapireturn WITH DEFAULT KEY .
  types:
    gtt_bdc_messages  TYPE STANDARD TABLE OF bdcmsgcoll WITH DEFAULT KEY .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !GT_RETURN type BAPIRET2_T optional
      !MSGTY type SYMSGTY optional .
  methods HAS_MESSAGES
    returning
      value(RV_HAS_MESSAGES) type ABAP_BOOL .
  methods GET_BAPIRET2_STRUC
    returning
      value(RS_BAPIRET2) type BAPIRET2 .
  methods GET_BAPIRET2_TABLE
    returning
      value(RT_BAPIRET2) type BAPIRET2_T .
  methods ADD_SYSTEM_MESSAGE
    importing
      !IV_FIELD_NAME type BAPI_FLD optional .
  methods ADD_MESSAGE_AND_TEXT_VAR
    importing
      !IV_TYPE type BAPI_MTYPE
      !IV_ID type SYMSGID
      !IV_NUMBER type SYMSGNO
      !IV_TEXT_VARIABLE type CHAR200 .
  methods ADD_EXCEPTION_OBJECT
    importing
      !IR_EXCEPTION_OBJECT type ref to CX_ROOT .
  methods ADD_BAPIRETURN_STRUC
    importing
      !IS_BAPIRETURN type BAPIRETURN .
  methods ADD_BAPIRETURN_TABLE
    importing
      !IT_RETURN type GTT_BAPIRETURN_T .
  methods ADD_BAPIRET1_STRUC
    importing
      !IS_RETURN type BAPIRET1 .
  methods ADD_BAPIRET1_TABLE
    importing
      !IT_RETURN type BAPIRET1_TAB .
  methods ADD_BAPIRET2_STRUC
    importing
      !IS_RETURN type BAPIRET2 .
  methods ADD_BAPIRET2_TABLE
    importing
      !IT_RETURN type BAPIRET2_T .
  methods ADD_BDC_TABLE
    importing
      !IT_BDC_MESSAGES type GTT_BDC_MESSAGES .
  methods ADD_TEXT
    importing
      !IV_TYPE type BAPI_MTYPE default 'E'
      !IV_MESSAGE type BAPI_MSG
      !IV_VARIABLE_1 type SYMSGV optional
      !IV_VARIABLE_2 type SYMSGV optional
      !IV_VARIABLE_3 type SYMSGV optional
      !IV_VARIABLE_4 type SYMSGV optional .

  methods IF_MESSAGE~GET_TEXT
    redefinition .
*
protected section.

  data GT_RETURN type BAPIRET2_T .

  methods MAP_TEXT_VAR_TO_BAPIRET2
    importing
      !IV_TYPE type BAPI_MTYPE
      !IV_ID type SYMSGID
      !IV_NUMBER type SYMSGNO
      !IV_TEXT type CHAR200
    returning
      value(RS_BAPIRET2) type BAPIRET2 .
  methods MAP_BAPIRETURN_TO_BAPIRET2
    importing
      !IS_BAPIRETURN type BAPIRETURN
    returning
      value(RS_BAPIRET2) type BAPIRET2 .
  methods MAP_BAPIRET1_TO_BAPIRET2
    importing
      !IS_BAPIRETURN type BAPIRET1
    returning
      value(RS_BAPIRET2) type BAPIRET2 .
  class-methods MAP_BDC_TO_BAPIRET2
    importing
      !IS_BDC_MESSAGE type BDCMSGCOLL
    returning
      value(RS_BAPIRET2) type BAPIRET2 .
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCX_RETURN3 IMPLEMENTATION.


  METHOD add_bapiret1_struc.

    DATA(ls_bapiret2_struc) = map_bapiret1_to_bapiret2( is_return ).

    add_bapiret2_struc( ls_bapiret2_struc ).

  ENDMETHOD.


  METHOD add_bapiret1_table.

    LOOP AT it_return
      ASSIGNING FIELD-SYMBOL(<ls_return>).

      add_bapiret1_struc( <ls_return> ).

    ENDLOOP.

  ENDMETHOD.


  METHOD add_bapiret2_struc.

    "Update GT_RETURN if instantiated by RAISE EXCEPTION.
    get_bapiret2_struc(  ).

    DATA(ls_return) = is_return.

    IF is_return-type CA 'EAX'.

      IF ls_return-id IS NOT INITIAL.

        MESSAGE
          ID     ls_return-id
          TYPE   ls_return-type
          NUMBER ls_return-number
          WITH
            ls_return-message_v1
            ls_return-message_v2
            ls_return-message_v3
            ls_return-message_v4
          INTO ls_return-message.

      ENDIF.

    ELSEIF is_return-type IS INITIAL.

      CONCATENATE
        is_return-message_v1
        is_return-message_v2
        is_return-message_v3
        is_return-message_v4
        INTO ls_return-message.

    ENDIF.

    APPEND ls_return TO gt_return.

    IF lines( gt_return ) = 1.

      msgty                    = is_return-type.

      if_t100_dyn_msg~msgv1    = is_return-message_v1.
      if_t100_dyn_msg~msgv2    = is_return-message_v2.
      if_t100_dyn_msg~msgv3    = is_return-message_v3.
      if_t100_dyn_msg~msgv4    = is_return-message_v4.

      if_t100_message~t100key-msgid = is_return-id.
      if_t100_message~t100key-msgno = is_return-number.

      IF if_t100_dyn_msg~msgv1 IS NOT INITIAL.
        if_t100_message~t100key-attr1 = 'IF_T100_DYN_MSG~MSGV1'.
      ENDIF.
      IF if_t100_dyn_msg~msgv2 IS NOT INITIAL.
        if_t100_message~t100key-attr2 = 'IF_T100_DYN_MSG~MSGV2'.
      ENDIF.
      IF if_t100_dyn_msg~msgv3 IS NOT INITIAL.
        if_t100_message~t100key-attr3 = 'IF_T100_DYN_MSG~MSGV3'.
      ENDIF.
      IF if_t100_dyn_msg~msgv4 IS NOT INITIAL.
        if_t100_message~t100key-attr4 = 'IF_T100_DYN_MSG~MSGV4'.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD add_bapiret2_table.

    LOOP AT it_return
      ASSIGNING FIELD-SYMBOL(<ls_return>).

      add_bapiret2_struc( <ls_return> ).

    ENDLOOP.

  ENDMETHOD.


  METHOD add_bapireturn_struc.

    DATA(ls_bapiret2) =
      map_bapireturn_to_bapiret2( is_bapireturn ).

    me->add_bapiret2_struc( ls_bapiret2 ).

  ENDMETHOD.


  METHOD add_bapireturn_table.

    LOOP AT it_return
      ASSIGNING FIELD-SYMBOL(<ls_return>).

      add_bapireturn_struc( <ls_return> ).

    ENDLOOP.

  ENDMETHOD.


  METHOD add_bdc_table.

    DATA lt_bapiret2          TYPE bapiret2_t.

    LOOP AT it_bdc_messages
      ASSIGNING FIELD-SYMBOL(<ls_bdc_message>).

      APPEND INITIAL LINE TO lt_bapiret2
        ASSIGNING FIELD-SYMBOL(<ls_bapiret2>).

      <ls_bapiret2> = map_bdc_to_bapiret2( <ls_bdc_message> ).

    ENDLOOP.

  ENDMETHOD.


  METHOD add_exception_object.

    "********************************************************
    "Split message text string into variables of length 50

    DATA(lv_text) = ir_exception_object->get_text( ).

    DATA:
      BEGIN OF ls_variables,
        msgv1(50),
        msgv2(50),
        msgv3(50),
        msgv4(50),
      END OF ls_variables.

    ls_variables = lv_text.

    "********************************************************
    "Add message

    DATA:
      ls_bapiret2 TYPE bapiret2.

    ls_bapiret2-message_v1  = ls_variables-msgv1.
    ls_bapiret2-message_v2  = ls_variables-msgv2.
    ls_bapiret2-message_v3  = ls_variables-msgv3.
    ls_bapiret2-message_v4  = ls_variables-msgv4.

    add_bapiret2_struc( ls_bapiret2 ).

  ENDMETHOD.


  METHOD add_message_and_text_var.

    DATA(ls_bapiret2) =
      map_text_var_to_bapiret2(
        iv_type           = iv_type
        iv_id             = iv_id
        iv_number         = iv_number
        iv_text           = iv_text_variable ).

    me->add_bapiret2_struc( ls_bapiret2 ).

  ENDMETHOD.


  METHOD add_system_message.

    DATA:
      ls_return TYPE bapiret2.

    ls_return-type        = sy-msgty.
    ls_return-id          = sy-msgid.
    ls_return-number      = sy-msgno.

    ls_return-message_v1  = sy-msgv1.
    ls_return-message_v2  = sy-msgv2.
    ls_return-message_v3  = sy-msgv3.
    ls_return-message_v4  = sy-msgv4.

    ls_return-field       = iv_field_name.

    add_bapiret2_struc( ls_return ).

  ENDMETHOD.


  METHOD add_text.

    "Example:
    "IV_TYPE         = 'E'
    "IV_MESSAGE      = 'Sales order &1 not found.'
    "IV_VARIABLE_1   = '100001
    "IV_VARIABLE_2   = ''
    "IV_VARIABLE_3   = ''
    "IV_VARIABLE_4   = ''

    DATA:
      lv_message TYPE bapi_msg,
      ls_return  TYPE bapiret2.

    lv_message = iv_message.

    DO 4 TIMES.


      DATA lv_placeholder_name TYPE c LENGTH 2.
      DATA lv_variable_name TYPE c LENGTH 15.

      lv_placeholder_name  = '&' && sy-index.

      lv_variable_name  = 'iv_variable_' && sy-index.

      ASSIGN (lv_variable_name)
        TO FIELD-SYMBOL(<lv_variable>).

      REPLACE ALL OCCURRENCES OF lv_placeholder_name
        IN lv_message
        WITH <lv_variable>
        IN CHARACTER MODE.

      DATA lv_return_var_name TYPE c LENGTH 15.

      lv_return_var_name = 'MESSAGE_V' && sy-index.

      ASSIGN COMPONENT lv_return_var_name
        OF STRUCTURE ls_return
        TO FIELD-SYMBOL(<lv_return_variable>).

      <lv_return_variable> = <lv_variable>.

    ENDDO.

    ls_return-type    = iv_type.
    ls_return-message = lv_message.

    add_bapiret2_struc( ls_return ).

  ENDMETHOD.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    me->msgty = msgty .
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.


  METHOD get_bapiret2_struc.

    IF gt_return[] IS INITIAL.

      IF if_t100_message~t100key-msgid = if_t100_message~default_textid-msgid AND
         if_t100_message~t100key-msgno = if_t100_message~default_textid-msgno.
        CLEAR if_t100_message~t100key.
      ENDIF.

      IF if_t100_message~t100key IS NOT INITIAL.

        MESSAGE
          ID          if_t100_message~t100key-msgid
          TYPE        msgty
          NUMBER      if_t100_message~t100key-msgno
          WITH
            if_t100_dyn_msg~msgv1
            if_t100_dyn_msg~msgv2
            if_t100_dyn_msg~msgv3
            if_t100_dyn_msg~msgv4
          INTO DATA(lv_message).

        DATA(ls_bapiret2) = VALUE bapiret2(
          type        = msgty
          id          = if_t100_message~t100key-msgid
          number      = if_t100_message~t100key-msgno
          message     = lv_message
          message_v1  = if_t100_dyn_msg~msgv1
          message_v2  = if_t100_dyn_msg~msgv2
          message_v3  = if_t100_dyn_msg~msgv3
          message_v4  = if_t100_dyn_msg~msgv4 ).

        APPEND ls_bapiret2 TO gt_return.

      ENDIF.

    ENDIF.

    READ TABLE gt_return
      INTO rs_bapiret2
      INDEX 1.

  ENDMETHOD.


  METHOD get_bapiret2_table.

    IF gt_return[] IS INITIAL.

      DATA(ls_bapiret2) = get_bapiret2_struc( ).

      APPEND ls_bapiret2 TO rt_bapiret2.

    ELSE.

      rt_bapiret2 = gt_return.

    ENDIF.

  ENDMETHOD.


  METHOD has_messages.
    IF gt_return[] IS NOT INITIAL.
      rv_has_messages = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD if_message~get_text.

    DATA(ls_return) = me->gt_return[ 1 ].

    IF ls_return-message IS NOT INITIAL.

      result = ls_return-message.

    ELSE.

      MESSAGE
        ID ls_return-id
        TYPE ls_return-type
        NUMBER ls_return-number
        WITH
          ls_return-message_v1
          ls_return-message_v2
          ls_return-message_v3
          ls_return-message_v4
      INTO result.

    ENDIF.

  ENDMETHOD.


  METHOD map_bapiret1_to_bapiret2.

    rs_bapiret2-type       = is_bapireturn-type.
    rs_bapiret2-id         = is_bapireturn-id.
    rs_bapiret2-number     = is_bapireturn-number.

    rs_bapiret2-message    = is_bapireturn-message.
    rs_bapiret2-log_no     = is_bapireturn-log_no.
    rs_bapiret2-log_msg_no = is_bapireturn-log_msg_no.

    rs_bapiret2-message_v1 = is_bapireturn-message_v1.
    rs_bapiret2-message_v2 = is_bapireturn-message_v2.
    rs_bapiret2-message_v3 = is_bapireturn-message_v3.
    rs_bapiret2-message_v4 = is_bapireturn-message_v4.

  ENDMETHOD.


  METHOD map_bapireturn_to_bapiret2.

    rs_bapiret2-type       = is_bapireturn-type.

    "Example value field code: IS504
    rs_bapiret2-id      = is_bapireturn-code+0(2).
    rs_bapiret2-number  = is_bapireturn-code+2(3).

    rs_bapiret2-message    = is_bapireturn-message.
    rs_bapiret2-log_no     = is_bapireturn-log_no.
    rs_bapiret2-log_msg_no = is_bapireturn-log_msg_no.
    rs_bapiret2-message_v1 = is_bapireturn-message_v1.
    rs_bapiret2-message_v2 = is_bapireturn-message_v2.
    rs_bapiret2-message_v3 = is_bapireturn-message_v3.
    rs_bapiret2-message_v4 = is_bapireturn-message_v4.

  ENDMETHOD.


  METHOD map_bdc_to_bapiret2.

    rs_bapiret2-type       = is_bdc_message-msgtyp.
    rs_bapiret2-id      = is_bdc_message-msgid.
    rs_bapiret2-number  = is_bdc_message-msgnr.

    rs_bapiret2-message_v1 = is_bdc_message-msgv1.
    rs_bapiret2-message_v2 = is_bdc_message-msgv2.
    rs_bapiret2-message_v3 = is_bdc_message-msgv3.
    rs_bapiret2-message_v4 = is_bdc_message-msgv4.

    MESSAGE
      ID rs_bapiret2-id
      TYPE rs_bapiret2-type
      NUMBER rs_bapiret2-number
      WITH
        rs_bapiret2-message_v1
        rs_bapiret2-message_v2
        rs_bapiret2-message_v3
        rs_bapiret2-message_v4
      INTO rs_bapiret2-message.

  ENDMETHOD.


  METHOD map_text_var_to_bapiret2.

    "***************************************************
    " Convert text to variables
    "***************************************************

    rs_bapiret2-type   = iv_type.
    rs_bapiret2-id     = iv_id.
    rs_bapiret2-number = iv_number.

    "***************************************************
    " Convert text to variables
    "***************************************************

    TYPES:
      BEGIN OF ltv_variable,
        text TYPE c LENGTH 50,
      END OF ltv_variable.

    DATA:
      lv_text_string TYPE string,
      lt_text        TYPE STANDARD TABLE OF ltv_variable.

    lv_text_string = iv_text.

    CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
      EXPORTING
        i_string         = lv_text_string
        i_tabline_length = 50
      TABLES
        et_table         = lt_text.

    LOOP AT lt_text ASSIGNING FIELD-SYMBOL(<ls_variable>).

      CASE sy-tabix.
        WHEN 1.
          rs_bapiret2-message_v1 = <ls_variable>-text.
        WHEN 2.
          rs_bapiret2-message_v2 = <ls_variable>-text.
        WHEN 3.
          rs_bapiret2-message_v3 = <ls_variable>-text.
        WHEN 4.
          rs_bapiret2-message_v4 = <ls_variable>-text.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
