//
//  nimbusOrderCreationOrderItemsExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-15.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit

extension nimbusOrderCreationFunctions {    
    func getOrderItemsForSelectedSeat() -> [orderItem] {
        let seatNumber = seat?.seatNumber ?? 1
        let orderItemsForSeat = orderItems.filter({$0.seatNumber == seatNumber})
        return orderItemsForSeat.sorted(by: {$0.itemNumber! < $1.itemNumber!})
    }
    
    func generateKeyForRedeemItem(item: orderItem) -> String {
        return "Redeem-" + generateKeyForItem(item: item)
    }
    
    func generateKeyForItem(item: orderItem) -> String {
        return generateKey(sizeCode: (item.size?.code)!, productId: (item.product?._id)!, addOns: item.addOns!, seatNumber: item.seatNumber!)
    }
    
    func generateKey(sizeCode: String, productId: String, addOns: [orderItemAddOns] = [], seatNumber: Int = 1) -> String {
        var key: String
        key = sizeCode + "-" + productId + getAddOnKey(addOnSet: addOns)
        return key
    }
    
    func getAddOnKey(addOnSet: [orderItemAddOns]) -> String {
        var addOnKey = ""
        
        var allProductAddOns = NIMBUS.AddOns?.getAllAddOnsAndSubstitutions().flatMap({return $0.id})
        allProductAddOns = allProductAddOns?.sorted(by: {$0 < $1})
        
        var indexSet = [Int]()

        let givenAddOnSet = addOnSet.flatMap({return $0._id})

        if givenAddOnSet.count >= 1 {
            for i in givenAddOnSet.indices {
                indexSet.append(allProductAddOns?.index(of: givenAddOnSet[i]) ?? 0)
            }
            
            let sortedIndex = indexSet.sorted()

            for j in sortedIndex.indices {
                addOnKey += "-" + String(sortedIndex[j])
            }
            return "-addon" + addOnKey
        } else {
            return ""
        }
    }
    
    func getOrderItemAtIndexPathForSelectedSeat(index: IndexPath)-> orderItem? {
        let itemsForSeat = getOrderItemsForSelectedSeat()
        return itemsForSeat[index.row]
    }
    
    func getItemByLocalId(localId: String) -> orderItem? {
        return self.orderItems.first(where: {$0.localId == localId})
    }
    
    func getItemByKey(itemKey: String, seatNumber: Int?) -> orderItem? {
        if let seatNumber = seatNumber {
            return self.orderItems.first(where: {$0.currentKey == itemKey && $0.seatNumber == seatNumber})
        } else {
            return self.orderItems.first(where: {$0.currentKey == itemKey})
        }
    }

    func getIndexOfOrderItem(byLocalId localId: String? = nil) -> Int? {
        if let localId = localId {
            return self.orderItems.index(where: {$0.localId == localId})
        }
        
        return nil
    }
    
    func getSelectedOrderItem() -> orderItem? {
        let localId = self.selectedOrderItem?.localId ?? " "
        return getItemByLocalId(localId: localId)
    }
    
    func addSelectedProductToOrderItems(selectedProductItem: productSchema, selectedSize: productSize, addQuantity: Int = 1){
        let addToOrderItem = createOrderItem(product: selectedProductItem, selectedSize: selectedSize, selectedQuantity: addQuantity, selectedAddOns: nil)
        let candidateKey = addToOrderItem.currentKey
        
        var existingOrderItem = getItemByKey(itemKey: addToOrderItem.currentKey!, seatNumber: addToOrderItem.seatNumber)
        
        if existingOrderItem != nil {
            incrementOrderItem(item: existingOrderItem!, addQuantity: addQuantity)
        } else {
            insertOrderItem(orderItem: addToOrderItem)
        }
        checkOrderForLoyaltyCreditItems()
    }
    
    func addRedeemItemToOrderItems(redeemItem: orderItem){
        self.insertOrderItem(orderItem: redeemItem)
    }
    
    func addDiscountItem(includeAddOns: Bool, discountPercent: Float, discountQuantity: Int){
        if let selectedOrderItem = self.selectedOrderItem {
            let baseRedeemItem = createBaseRedeemItemFromOrderItem(referenceOrderItem: selectedOrderItem, isManualDiscount: true)
            let addToOrderItem = applyRequestedDiscountFeatures(referenceProductItem: selectedOrderItem, baseRedeemItem: baseRedeemItem, requestedQuantity: discountQuantity, discountPercent: discountPercent, includeAddOns: includeAddOns)
            addRedeemItemToOrderItems(redeemItem: addToOrderItem)
        }
    }
    
    func setOrderItem(withLocalId localId: String?, item: orderItem){
        if let localId = localId{
            let index = getIndexOfOrderItem(byLocalId: localId)
            setOrderItemAtIndex(row: index, item: item)
        } else {
            insertOrderItem(orderItem: item)
        }
    }
    
    func setOrderItemAtIndex(row: Int?, item: orderItem){
        if let row = row {
            self.orderItems[row] = item
        }
    }
    
    func insertOrderItem(orderItem: orderItem){
        self.orderItems.append(orderItem)
    }
    
    func insertLoyaltyProgramOrderItem(loyaltyOrderItem: orderItem){
        self.orderItems.append(loyaltyOrderItem)
    }

    func incrementOrderItem(item: orderItem, addQuantity: Int = 1){
        if let index = getIndexOfOrderItem(byLocalId: item.localId){
            self.orderItems[index].quantity += addQuantity
        }
        checkOrderForLoyaltyCreditItems()
    }
    
    func setOrderItemQuantity(item: orderItem, setQuantity: Int){
        if let index = getIndexOfOrderItem(byLocalId: item.localId){
            self.orderItems[index].quantity = setQuantity
        }
    }
    
    func decrementOrderItem(item: orderItem){
        if let index = getIndexOfOrderItem(byLocalId: item.localId){
            if self.orderItems[index].quantity > 1 {
                self.orderItems[index].quantity -= 1
            } else {
                //quantity <= 1 so can not decrement
            }
        }
        checkOrderForLoyaltyCreditItems()
    }
    
    func removeOrderItem(item: orderItem){
        if let index = getIndexOfOrderItem(byLocalId: item.localId){
            self.orderItems.remove(at: index)
        }
        checkOrderForLoyaltyCreditItems()
    }
    
    func updateOrderItemVariablePrice(item: orderItem, newVariablePrice: Float){
        let updateVariablePrice = newVariablePrice < 0 ? 0 : newVariablePrice
        
        if let index = getIndexOfOrderItem(byLocalId: item.localId){
            if item.unitBasedPrice == true {
                self.orderItems[index].unitPrice = updateVariablePrice
                self.orderItems[index].size?.price = updateVariablePrice * (item.unitBasedPriceQuantity ?? 1)
            } else {
                self.orderItems[index].size?.price = updateVariablePrice
            }
        }
    }
    
    func updateOrderItemUnitQuantity(item: orderItem, newUnitQuantity: Float){
        let updateUnitQuantity = newUnitQuantity < 0 ? 0 : newUnitQuantity
        
        if let index = getIndexOfOrderItem(byLocalId: item.localId){
            self.orderItems[index].unitBasedPriceQuantity = updateUnitQuantity
            self.orderItems[index].size?.price = (self.orderItems[index].unitPrice ?? 0) * updateUnitQuantity
        }
    }
    
    func createBaseRedeemItemFromOrderItem(referenceOrderItem: orderItem, isManualDiscount: Bool = false) -> orderItem {
        // does not return addons or total. quantity = 1
        var redeemItem = orderItem()
        
        redeemItem.itemNumber = getNextRedeemItemNumber(referenceItemNumber: referenceOrderItem.itemNumber!)
        redeemItem.product = referenceOrderItem.product
        redeemItem.seatNumber = referenceOrderItem.seatNumber
        redeemItem.sentToKitchen = true //TO-DO: need to find a better way to bypass redeem items from being sent to kitchen
        redeemItem.isRedeemItem = true
        redeemItem.isManualRedeem = isManualDiscount
        redeemItem.variablePrice = referenceOrderItem.variablePrice
        redeemItem.unitBasedPrice = referenceOrderItem.unitBasedPrice
//        redeemItem.unitBasedPriceQuantity = Float?
//        redeemItem.unitPrice: Float?
        redeemItem.unitLabel = referenceOrderItem.unitLabel
        redeemItem.size = referenceOrderItem.size
        redeemItem.addOns = [orderItemAddOns]()
        redeemItem.quantity = 1
        
//        redeemItem.taxRule = referenceOrderItem.taxRule
//        redeemItem.currentKey = generateKeyForItem(item: redeemItem)
        
        redeemItem = populateOrderItemLocalHelperVariables(item: redeemItem)
        
        return redeemItem
    }
    
    func createOrderItem(product: productSchema, selectedSize: productSize, selectedQuantity: Int, selectedAddOns: [orderItemAddOns]?) -> orderItem {
        var item = orderItem()
        
        item.itemNumber = getNextItemNumber()
        item.product = orderProduct(_id: (product._id)!, name: product.name, sizes: product.sizes)
        item.seatNumber = seat?.seatNumber ?? 1
        item.sentToKitchen = false
        item.isRedeemItem = false
        item.isManualRedeem = false
        item.variablePrice =  product.isVariablePrice ?? false
        item.unitBasedPrice = product.isUnitBasedPrice ?? false
        item.unitBasedPriceQuantity = 1
        item.unitPrice = selectedSize.price
        item.unitLabel = product.unitLabel
        item.notes = [String]()
        item.size = selectedSize
        item.addOns = selectedAddOns ?? [orderItemAddOns]()
        item.quantity = selectedQuantity
        //            item.redeemed: Int?
        
//        item.localId = UUID().uuidString
//        item.isExpanded = false
//        item.taxRule = product.taxRule
//        item.currentKey = generateKeyForItem(item: item)

        item = populateOrderItemLocalHelperVariables(item: item)
        
        return item
    }
    
    func populateOrderItemLocalHelperVariables(item: orderItem) -> orderItem {
        var localItem: orderItem = item
        
        localItem.currentKey = generateKeyForItem(item: localItem)

        if let productId = item.product?._id {
            let product = NIMBUS.Products?.getProductById(productId: productId)
            localItem.taxRule = product?.taxRule
        }
        
        //  There variables are auto populated at schema initiation
        //        localItem.localId
        //        localItem.isExpanded
        //        localItem.isLoyaltyProgram
        
        return localItem
    }
    
    func addRedeemItem(item: orderItem, selectedQuantity: Int, discountPercent: Float, includeAddOns: Bool, isManualRedeem: Bool){  //discount percent in decimal
        var redeemProduct = item.product

        var redeemOrderItem = createBaseRedeemItemFromOrderItem(referenceOrderItem: item, isManualDiscount: isManualRedeem)
        redeemOrderItem.size?.price = (redeemOrderItem.size?.price)! * (-1) * (discountPercent)
        
        redeemProduct?.sizes = [redeemOrderItem.size!]
        redeemProduct?.name = "Redeem - " + (redeemProduct?.name!)!
        
        redeemOrderItem.product = redeemProduct
//        redeemProduct._id = "Redeem-" + generateKey(sizeCode: selectedSizeCode!, productId: (redeemProduct._id)!, addOns: selectedAddOns!, seatNumber: seatNumber!)
        
        if(!includeAddOns){
            redeemOrderItem.addOns = [];
        } else {
            redeemOrderItem.addOns = item.addOns.map({(allAddOns) -> [orderItemAddOns] in
                return allAddOns.map({(addOn) -> orderItemAddOns in
                    var redeemAddOn = addOn
                    redeemAddOn.price = (-1)*(discountPercent) * (addOn.price ?? 0)
                    return redeemAddOn
                })
            })
        }
        
        let key = generateKeyForRedeemItem(item: redeemOrderItem)
        redeemOrderItem.currentKey = key
        redeemOrderItem.product?._id = key
        
        if let item = getItemByKey(itemKey: key, seatNumber: item.seatNumber) {
            redeemOrderItem = item
            redeemOrderItem.quantity = selectedQuantity
            setOrderItemQuantity(item: redeemOrderItem, setQuantity: selectedQuantity)
        } else {
            redeemOrderItem.quantity = selectedQuantity
            addRedeemItemToOrderItems(redeemItem: redeemOrderItem)
        }
    }
    
    func addLoyaltyProgramPurchase(loyaltyProgram: loyaltyProgramSchema, quantity: Int){
        let loyaltyProduct = loyaltyProgram.getProgramAsProduct()
        let candidateSize = loyaltyProduct.sizes![0]
        var candidateKey: String
    
        var loyaltyOrderItem = createOrderItem(product: loyaltyProduct, selectedSize: candidateSize, selectedQuantity: quantity, selectedAddOns: nil)
        loyaltyOrderItem.isLoyaltyProgram = true
        candidateKey = generateKeyForItem(item: loyaltyOrderItem)
    
        var existingOrderItem = getItemByKey(itemKey: candidateKey, seatNumber: self.seat?.seatNumber)
        
        if existingOrderItem != nil {
            incrementLoyaltyProgramPurchase(orderLoyaltyItem: existingOrderItem!, increaseQuantity: 1)
        } else {
            insertLoyaltyProgramOrderItem(loyaltyOrderItem: loyaltyOrderItem)
            addPrePurchaseLoyaltyCard(loyaltyOrderItem: loyaltyOrderItem, program: loyaltyProgram)
        }
    }
    
    func incrementLoyaltyProgramPurchase(orderLoyaltyItem: orderItem, increaseQuantity: Int = 1 ){
        let loyaltyProgram = NIMBUS.LoyaltyPrograms?.getLoyaltyProgram(byId: (orderLoyaltyItem.product?._id)!)
        if loyaltyProgram?.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Coupon {
            
        } else {
            incrementOrderItem(item: orderLoyaltyItem)
            if let updatedOrderItem = getItemByLocalId(localId: orderLoyaltyItem.localId) {
                updatePrePurchaseLoyaltyCardQuantities(loyaltyOrderItem: updatedOrderItem)
                reApplyLoyaltyPrograms()
            }
        }
    }
    
    func decrementLoyaltyProgramPurchase(orderLoyaltyItem: orderItem, decreaseQuantity: Int = -1 ){
        let loyaltyProgram = NIMBUS.LoyaltyPrograms?.getLoyaltyProgram(byId: (orderLoyaltyItem.product?._id)!)
        if loyaltyProgram?.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Coupon {
            
        } else {
            decrementOrderItem(item: orderLoyaltyItem)
            if let updatedOrderItem = getItemByLocalId(localId: orderLoyaltyItem.localId) {
                updatePrePurchaseLoyaltyCardQuantities(loyaltyOrderItem: updatedOrderItem)
                reApplyLoyaltyPrograms()
            }
        }
    }
    
    func removeLoyaltyProgramPurchase(orderLoyaltyItem: orderItem){
        removePrePurchaseLoyaltyCard(programId: (orderLoyaltyItem.product?._id)!)
        removeOrderItem(item: orderLoyaltyItem)
    }
    
    func addSelectedAddOnToOrderItem(selectedAddOn: orderItemAddOns){
        if var item = getSelectedOrderItem() {
            if !item.addOns!.isEmpty {
                item.addOns!.append(selectedAddOn)
            } else {
                item.addOns = [selectedAddOn]
            }
            item.currentKey = generateKeyForItem(item: item)
            setOrderItem(withLocalId: item.localId, item: item)
        }
        self.itemOptionsManagerDelegate?.refreshAddOnsAndSubsData()
    }
    
    func removeSelectedAddOnFromOrderItem(selectedAddOn: orderItemAddOns){
        if var item = getSelectedOrderItem() {
            if !item.addOns!.isEmpty {
                if let removeIndex = item.addOns!.index(where: {$0._id == selectedAddOn._id}){
                    item.addOns?.remove(at: removeIndex)
                }
            }
            item.currentKey = generateKeyForItem(item: item)
            setOrderItem(withLocalId: item.localId, item: item)
        }
        self.itemOptionsManagerDelegate?.refreshAddOnsAndSubsData()
    }
    
    func getOrderItemNotes() -> [String]{
        if let item = getSelectedOrderItem() {
            return item.notes ?? [String]()
        }
        return [String]()
    }
    
    func addNoteToOrderItem(note: String){
        if var item = getSelectedOrderItem() {
            if let _ = item.notes {
                item.notes?.append(note)
            } else {
                item.notes = [note]
            }
            setOrderItem(withLocalId: item.localId, item: item)
        }
        self.itemOptionsManagerDelegate?.refreshNotes()
    }
    
    func removeNoteFromOrderItem(note: String){
        if var item = getSelectedOrderItem() {
            if let _ = item.notes {
                if let index = item.notes?.index(where: {$0 == note}){
                    item.notes?.remove(at: index)
                }
            }
            setOrderItem(withLocalId: item.localId, item: item)
        }
        self.itemOptionsManagerDelegate?.refreshNotes()
    }
}

/*
Maestro.POS.OrderItems.clear = function(template){
    template.orderItemsCollection.remove({});
    template.orderItemsCache.set();
};

Maestro.POS.OrderItems.setItem = function(template, key, orderItem, seatNumber){
    // console.log('key: ', key);
    // console.log('order item: ', orderItem);

    let existingItem = Maestro.POS.OrderItems.getItem(template, key, seatNumber);
    if(!!existingItem){
        let updateAttr = _.omit(orderItem, '_id');
        // console.log('updateAttr', updateAttr);
        template.orderItemsCollection.update({_id: existingItem._id},{$set: updateAttr});
        Maestro.POS.OrderItems.scrollToItemAndHighlight(existingItem._id);
    } else {
        let itemId = template.orderItemsCollection.insert(orderItem);
        Maestro.POS.OrderItems.scrollToItemAndHighlight(itemId);
    }

    // console.log(template.orderItemsCollection.find({}).fetch());
};

Maestro.POS.OrderItems.setItemAttr = function(template, orderItem, modifyAttr){
    template.orderItemsCollection.update({_id: orderItem._id}, {$set: modifyAttr});
};

Maestro.POS.OrderItems.setAllItemsAttr = function(template, modifyAttr){
    template.orderItemsCollection.update({}, {$set: modifyAttr});
};

Maestro.POS.OrderItems.increaseQuantity = function(template, orderItem, increment){
    template.orderItemsCollection.update({_id: orderItem._id}, {$inc: {quantity: increment}});
};

Maestro.POS.OrderItems.setQuantity = function(template, orderItem, quantity){
    template.orderItemsCollection.update({_id: orderItem._id}, {$set: {quantity: quantity}});
};

Maestro.POS.OrderItems.getItem = function(template, key, seatNumber = null){
    if(seatNumber){
        return template.orderItemsCollection.findOne({currentKey: key, seatNumber: seatNumber});
    } else {
        return template.orderItemsCollection.findOne({currentKey: key});
    }
};

Maestro.POS.OrderItems.getItemWithId = function(template, itemId){
    return template.orderItemsCollection.findOne({_id: itemId});
};

Maestro.POS.OrderItems.getAllItems = function(template){
    return template.orderItemsCollection.find({}).fetch();
};

Maestro.POS.OrderItems.getAllSeatItems = function(template, seatNumber = null){
    if(seatNumber == "ALL"){
        return template.orderItemsCollection.find({}).fetch();
    } else if (!!seatNumber){
        return template.orderItemsCollection.find({seatNumber: seatNumber}).fetch();
    } else {
        let seat = template.selectedSeat.get();
        let selectedSeatNumber = seat ? seat.seatNumber : null;
        if(!!selectedSeatNumber){
            return template.orderItemsCollection.find({seatNumber: selectedSeatNumber}).fetch();
        }
    }
};

Maestro.POS.OrderItems.getAllSeatItemsWithAttr = function(template, seatNumber = null, attrDetails){
    let searchAttr = attrDetails || {};
    searchAttr.seatNumber = seatNumber;

    if(seatNumber == "ALL"){
        return template.orderItemsCollection.find({}).fetch();
    } else if (!!seatNumber){
        return template.orderItemsCollection.find(searchAttr).fetch();
    } else {
        let seat = template.selectedSeat.get();
        let selectedSeatNumber = seat ? seat.seatNumber : null;
        searchAttr.seatNumber = selectedSeatNumber;
        if(!!selectedSeatNumber){
            return template.orderItemsCollection.find(searchAttr).fetch();
        }
    }
};

Maestro.POS.OrderItems.getSeatsUsed = function(template){
    let allUsedSeats = template.orderItemsCollection.find({},{fields: {seatNumber:1}}).fetch();
    allUsedSeats = _.pluck(allUsedSeats, "seatNumber");
    allUsedSeats = _.uniq(allUsedSeats);
    return allUsedSeats;
};

Maestro.POS.OrderItems.getAllItemKeys = function(template){
    // console.log('all items: ', Maestro.POS.OrderItems.getAllItems(template));
    // console.log('pluck current keys: ', _.pluck(Maestro.POS.OrderItems.getAllItems(template), 'currentKey'));
    return  _.pluck(Maestro.POS.OrderItems.getAllItems(template), 'currentKey');
};

Maestro.POS.OrderItems.removeItem = function(template, key = null, itemId = null){
    let removed;
    // console.log('entering remove item with: ', key, itemId);

    if(itemId){
        removed = template.orderItemsCollection.remove({_id: itemId});
    } else if (key){
        removed = template.orderItemsCollection.remove({currentKey: key});
        // console.log('removed items (key): ', removed);
    }
    
    // console.log(template.orderItemsCollection.find({}).fetch());
};

Maestro.POS.OrderItems.removeAllItems = function(template){
    template.orderItemsCollection.remove({});
};

Maestro.POS.OrderItems.addBackItemsChunk = function(template, items){
    _.each(items, function(item){
        template.orderItemsCollection.insert(item);
    });
};

Maestro.POS.OrderItems.initializeSeatSplit = function(template){
    let allUsedSeats = Maestro.POS.OrderItems.getSeatsUsed(template);
    let seatAndItems = _.map(allUsedSeats, function(num){
        return {seatNumber: num,
                seatItems: Maestro.POS.OrderItems.getAllSeatItems(template, num)
            };
    });
    template.seatGrouping.set(seatAndItems);

    template.orderItemsCache.set(Maestro.POS.OrderItems.getAllItems(template));
};

Maestro.POS.OrderItems.initializeGroupSplit = function(template){
    let allUsedSeats = Maestro.POS.OrderItems.getSeatsUsed(template);

    let seatAndItems = _.map(allUsedSeats, function(num){
        return {seatNumber: num,
                selectedForGroup: false
                };
    });

    template.ungroupedSeats.set(seatAndItems);
};

Maestro.POS.OrderItems.thisGroupDone = function(template){
    let selectedSeats = _.where(template.ungroupedSeats.get(), {selectedForGroup: true});

    if(selectedSeats.length == 0){
        return;
    }

    let definedGroups = template.definedGroups.get();
    let nextGroup = !!definedGroups ? definedGroups.length + 1 : 1;
    // console.log(_.pluck(selectedSeats, "seatNumber"));
    let newGroup = {
        groupNumber: definedGroups.length + 1,
        selectedSeats: selectedSeats,
        groupLabel: (_.pluck(selectedSeats, "seatNumber")).join(" & ")
    };

    definedGroups.push(newGroup);

    template.definedGroups.set(definedGroups);

    let unselectedSeats = _.where(template.ungroupedSeats.get(), {selectedForGroup: false});
    template.ungroupedSeats.set(unselectedSeats);
    // console.log(unselectedSeats);
    if(unselectedSeats.length== 0){
        Maestro.POS.OrderItems.finalizeGroupSplitSelection(template);
    } else if (unselectedSeats.length == 1){
        let seatNumber = unselectedSeats[0].seatNumber;
        Maestro.POS.OrderItems.toggleSeatSelectionToGroup(template, seatNumber);
        Maestro.POS.OrderItems.thisGroupDone(template);
    }
};

Maestro.POS.OrderItems.toggleSeatSelectionToGroup = function(template, seatNumber){
    let ungroupedSeats = template.ungroupedSeats.get();
    ungroupedSeats = _.map(ungroupedSeats, function(seat){
        if(seat.seatNumber == seatNumber){
            seat.selectedForGroup = !seat.selectedForGroup;
        }
        return seat;
    });
    template.ungroupedSeats.set(ungroupedSeats);
};

Maestro.POS.OrderItems.finalizeGroupSplitSelection = function(template){
    let definedGroups = template.definedGroups.get();

    let seatAndItems = _.map(definedGroups, function(group){
        let groupedSeatItems = [];
        _.each(group.selectedSeats, function(seat){
            // console.log()
            groupedSeatItems = $.merge(groupedSeatItems, Maestro.POS.OrderItems.getAllSeatItems(template, seat.seatNumber));
        });
        // console.log(groupedSeatItems);
        return {seatNumber: group.groupLabel,
                seatItems: groupedSeatItems
        };
    });
    template.seatGrouping.set(seatAndItems);

    template.orderItemsCache.set(Maestro.POS.OrderItems.getAllItems(template));
};

Maestro.POS.OrderItems.isolateSeatItemsForCheckout = function(template){
    let checkoutSeat = template.checkoutSeatSelected.get();
    let seatItemsGroup = _.findWhere(template.seatGrouping.get(), {seatNumber: checkoutSeat});
    let seatItems = !!seatItemsGroup ? seatItemsGroup.seatItems : [];

    Maestro.POS.OrderItems.removeAllItems(template);
    Maestro.POS.OrderItems.addBackItemsChunk(template, seatItems);
};

Maestro.POS.OrderItems.deleteIncompleteSplitOrders = function(template){
    let seatGroups = template.seatGrouping.get();
    _.each(seatGroups, function(seatGroup){
        if(!!seatGroup.splitOrderId){
            Maestro.Order.Delete(seatGroup.splitOrderId);
        }
    });
};

Maestro.POS.OrderItems.restoreFromCache = function(template){
    if(!!template.orderItemsCache.get()){
        Maestro.POS.OrderItems.removeAllItems(template);
        Maestro.POS.OrderItems.addBackItemsChunk(template, template.orderItemsCache.get());
        Maestro.POS.OrderItems.deleteIncompleteSplitOrders(template);
    }
    template.checkoutSeatSelected.set();
    template.definedGroups.set([]);
    template.ungroupedSeats.set([]);
};

Maestro.POS.OrderItems.scrollToItem = function(itemId){
    Tracker.afterFlush(function(){
        document.getElementById(itemId).scrollIntoView()
        $('#'+itemId).removeClass('fadeOut').addClass('fadeIn');
    });
};

Maestro.POS.OrderItems.scrollToItemAndHighlight = function(itemId){
    Tracker.afterFlush(function(){
        if(!!document.getElementById(itemId)){
            document.getElementById(itemId).scrollIntoView();
        }
        $('#'+itemId).addClass('fadeOut');
        window.setTimeout(function(){
            $('#'+itemId).removeClass('fadeOut').addClass('fadeIn');
        }, 500);

    });
};
*/
