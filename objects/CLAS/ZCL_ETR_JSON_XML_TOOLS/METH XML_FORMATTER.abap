  METHOD xml_formatter.
*    DATA: o_ixml          TYPE REF TO if_ixml_core,
*          o_streamfactory TYPE REF TO if_ixml_stream_factory_core,
*          o_parser        TYPE REF TO if_ixml_parser_core,
*          o_istream       TYPE REF TO if_ixml_istream_core,
*          o_document      TYPE REF TO if_ixml_document,
*          o_nodes         TYPE REF TO if_ixml_node,
*          o_node          TYPE REF TO if_ixml_node,
*          o_parent        TYPE REF TO if_ixml_node,
*          o_filter        TYPE REF TO if_ixml_node_filter.
*
*    DATA: o_iterator  TYPE REF TO if_ixml_node_iterator.
*
*    DATA: lv_type TYPE c,
*          name    TYPE string,
*          parent  TYPE string.
*
*    CLEAR: me->id,me->tt_elementskey.

    DATA(lo_ixml) = cl_ixml_core=>create( ).
    DATA(lo_streamfactory) = lo_ixml->create_stream_factory( ).
    DATA(lo_ostream) = lo_streamfactory->create_ostream_xstring( string = xml ).
    lo_ostream->set_pretty_print( ).
    DATA(lo_document) = lo_ixml->create_document( ).
*    lo_document->get

*    o_streamfactory = o_ixml->create_stream_factory( ).
*    o_istream       = o_streamfactory->create_istream_xstring( string = xml )->.
*    o_document      = o_ixml->create_document( ).
  ENDMETHOD.