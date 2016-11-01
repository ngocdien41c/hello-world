SELECT 'SPVB_COL_DEP_AR_SUMMARY',
        S1.customer_id,                                      
        Max(S1.customer_site_id),                            
        S1.inventory_item_id,                                
        S1.col_line_id,                                      
        Max(S1.col_credit_limit)    col_credit_limit,        
        Max(S1.col_hold_quantity)   col_hold_quantity,       
        Sum(S1.order_quantity)      order_quantity,          
        Sum(S1.col_return_quantity) col_return_quantity,     
        Sum(S1.order_return_quantity) order_return_quantity, 
        Sum(S1.adjust_quantity)     adjust_quantity,         
        Sum(S1.deposit_quantity)    deposit_quantity,        
        Max(S1.col_deposit_quantity) col_deposit_quantity    
FROM (                              
    SELECT                          
            HEAD.customer_id,       
            HEAD.customer_site_id,  
            LINE.inventory_item_id, 
            LINE.col_line_id,       
            LINE.col_credit_limit,  
            NVL(LINE.col_shipped_quantity, 0) + NVL(LINE.col_adjust_quantity, 0) col_hold_quantity, LINE.col_deposit_quantity ,                        
            CASE WHEN TRXN.transaction_type = '1' THEN Nvl(TRXN.transaction_quantity, 0) ELSE 0 END order_quantity,  
            0 col_return_quantity, 
            CASE WHEN TRXN.transaction_type = '2' THEN Nvl(TRXN.transaction_quantity, 0) ELSE 0 END order_return_quantity, 
            CASE WHEN TRXN.transaction_type = '3' THEN Nvl(TRXN.transaction_quantity, 0)       ELSE 0 END adjust_quantity, 
            CASE WHEN TRXN.transaction_type = '4' THEN Nvl(TRXN.transaction_quantity, 0) * -1  ELSE 0 END + 
            CASE WHEN TRXN.transaction_type = '5' THEN Nvl(TRXN.transaction_quantity, 0)       ELSE 0 END deposit_quantity 
      FROM      spvb_col_credit_headers_tbl HEAD                                               
      JOIN      spvb_col_credit_lines_tbl   LINE ON HEAD.col_header_id = LINE.col_header_id    
      LEFT JOIN spvb_col_credit_details_tbl TRXN ON (TRXN.col_line_id = LINE.col_line_id AND (TRXN.transaction_date BETWEEN :l_start_date AND :l_end_date) AND NVL(TRXN.source_data, '?') != 'OM')      
     WHERE (HEAD.org_id = 88)
       AND (LINE.active_flag        = 'Y')  
AND HEAD.customer_id IN (11681)    UNION ALL                          
    SELECT /*+ORDERED */               
            HEAD.customer_id,       
            HEAD.customer_site_id,  
            LINE.inventory_item_id, 
            LINE.col_line_id,       
            LINE.col_credit_limit,  
            NVL(LINE.col_shipped_quantity, 0) + NVL(LINE.col_adjust_quantity, 0) col_hold_quantity, LINE.col_deposit_quantity ,                        
            CASE WHEN TRXN.transaction_type = '1' THEN Nvl(TRXN.transaction_quantity, 0) ELSE 0 END order_quantity,  
            CASE WHEN OT.NAME like '__.COL Return' AND TRXN.transaction_type = '2' THEN Nvl(TRXN.transaction_quantity, 0) ELSE 0 END col_return_quantity, 
            CASE WHEN OT.NAME like '__.COL Return' AND TRXN.transaction_type = '2' THEN 0 WHEN TRXN.transaction_type = '2' THEN Nvl(TRXN.transaction_quantity, 0) ELSE 0 END order_return_quantity, 
            0 adjust_quantity, 
            0 deposit_quantity 
      FROM spvb_col_credit_headers_tbl HEAD                                               
      JOIN spvb_col_credit_lines_tbl   LINE ON HEAD.col_header_id = LINE.col_header_id    
      JOIN spvb_col_credit_details_tbl TRXD ON (TRXD.col_line_id = LINE.col_line_id)      
      JOIN spvb_col_details_tbl        TRXN ON (TRXD.col_detail_id = TRXN.col_detail_id)  
      LEFT JOIN oe_order_lines_all      OL ON (TRXD.oe_line_id = OL.line_id)               
      LEFT JOIN oe_order_headers_all    OH ON (OL.header_id = OH.header_id)                
      LEFT JOIN oe_transaction_types_tl OT ON (OH.order_type_id = OT.transaction_type_id)  
     WHERE (HEAD.org_id = 88)
       AND (TRXN.transaction_date BETWEEN :l_start_date AND :l_end_date) 
       AND (LINE.active_flag        = 'Y')  
AND HEAD.customer_id IN (11681)
    ) S1                       
GROUP BY S1.customer_id,       
        S1.inventory_item_id,  
        S1.col_line_id
        
select * from mtl_system_items_b where segment1 = '35100025' and rownum < 2

begin
    spvb_reports_pkg.spvb_col_dep_ar_summary(
        i_request_id        => -1,
        i_start_date        => '29-FEB-2016',
        i_end_date          => '29-FEB-2016',
        i_customer_number   => 1004513
    );
end;    

select * from spvb_temp_area_tbl

select * from spvb_col_credit_headers_tbl where customer_id = 11681        
