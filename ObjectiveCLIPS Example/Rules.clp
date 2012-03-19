(deffunction updateTotalPurchase (?bill) "updates total purchase sum on a bill"
([|sum array | 
    sum := 0. 
    array := ?bill items allObjects.
    0 to: (array count-1) do: 
    [:i ||x| 
        x := ((array at: i) amount). 
        (x = nil) ifFalse:[sum := sum + x]
    ]. 
    ?bill setTotalPurchase: sum])
)

(deffunction updateTotalTax (?bill) "updates total tax on a bill"
([|sum array | 
    sum := 0. 
    array := ?bill items allObjects.
    0 to: (array count-1) do: 
    [:i ||x| 
        x := ((array at: i) tax). 
        (x = nil) ifFalse:[sum := sum + x]
    ]. 
    ?bill setTotalTax: sum])
)

(deffunction createObject (?entityName ?environment)
    "creates a new object"
    ([|context object|
        context := ?environment templateDelegate.
        object := NSEntityDescription insertNewObjectForEntityForName:?entityName 
											   inManagedObjectContext:context.])
)

(defrule exists-catalog-item
	"automatically create one catalog item"
	(not (exists (CatalogItem (itemDescription ?description))))
	=>
	; (assert (CatalogItem (itemDescription "Default item")
	; 					 (price 10.0)
	; 					 (taxable false)))
)

(defrule init-new-catalog-item
	"automatically create one catalog item"
	(KBEnvironment (self ?env))
	(not (exists (CatalogItem (itemDescription ?description))))
	=>
	([|context object|
        context := ?env templateDelegate.
        object := NSEntityDescription insertNewObjectForEntityForName:'CatalogItem' 
											   inManagedObjectContext:context.])
    
	; (assert (CatalogItem (itemDescription "Default item")
	; 					 (price 10.0)
	; 					 (taxable false)))
)

(defrule init-new-purchase-item-quantity 
    "newly created purchase items should have a quantity of 1"
    ?p<-(PurchaseItem (quantity nil))
    =>
    ([?p setQuantity: 2. ?p setAmount: 1. ?p setTax: 0]))

(defrule purchase-item-amount 
    "the purchase item amount is quantity times price"
    (KBEnvironment (self ?env))
    (CatalogItem (self ?cat) (price ?price&~nil))
    ?p<-(PurchaseItem (billOfSale ?bill&~nil)
                      (catalogItem ?cat)
                      (quantity ?quantity&~nil)
                      (amount ?amount&:([(?amount - (?price * ?quantity)) abs > 0.001]))) 
    =>
    ([?p setAmount: (?price * ?quantity)])    
    (updateTotalPurchase ?bill)
)

(defrule non-taxable-items-have-zero-tax 
    "purchase items that are not taxable have tax set to zero"
    (CatalogItem (self ?cat) (taxable FALSE))
    ?p<-(PurchaseItem (billOfSale ?bill&~nil)
                      (catalogItem ?cat)
                      (tax ~0.0))
    =>
    ([?p setTax: 0])
    (updateTotalTax ?bill))

(defrule purchase-item-tax 
    "purchase items that are taxable have tax set to amount times tax rate"
    (CatalogItem (self ?cat) (taxable TRUE))
    (TaxRate (percentage ?taxRate&~nil))
    ?p<-(PurchaseItem (billOfSale ?bill&~nil)
                      (catalogItem ?cat) 
                      (amount ?amount&~nil)
                      (tax ?tax&:([(?tax - ((?amount*?taxRate)/100)) abs > 0.001]))) 
    =>
    ([?p setTax: ((?amount * ?taxRate)/100.0)])
    (updateTotalTax ?bill))

(defrule bill-total
    "bill total is totalPurchase plus totalTax"
    ?b<-(BillOfSale (totalPurchase ?purchase&~nil)
                    (totalTax ?tax&~nil)
                    (total ?total&:([(?total - (?purchase+?tax)) abs > 0.001])))
    =>
    ([?b setTotal: (?purchase+?tax)]))