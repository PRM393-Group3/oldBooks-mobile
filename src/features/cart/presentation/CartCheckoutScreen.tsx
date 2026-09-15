import React, { useState } from 'react';
import { ScreenId, CartItem } from '../../../core/types';

interface CartCheckoutScreenProps {
  onNavigate: (screen: ScreenId) => void;
  cartItems: CartItem[];
  onUpdateQuantity: (bookId: string, delta: number) => void;
  onRemoveItem: (bookId: string) => void;
  onPlaceOrder: (total: number) => void;
}

export const CartCheckoutScreen: React.FC<CartCheckoutScreenProps> = ({
  onNavigate,
  cartItems,
  onUpdateQuantity,
  onRemoveItem,
  onPlaceOrder
}) => {
  const [shippingMethod, setShippingMethod] = useState<'standard' | 'express'>('standard');
  const [paymentMethod, setPaymentMethod] = useState<'apple_pay' | 'card' | 'wallet'>('apple_pay');
  const [promoCode, setPromoCode] = useState('');
  const [discount, setDiscount] = useState(0);
  const [promoApplied, setPromoApplied] = useState(false);

  const subtotal = cartItems.reduce((sum, item) => sum + item.book.price * item.quantity, 0);
  const shippingCost = shippingMethod === 'standard' ? 3.99 : 7.99;
  const escrowFee = 1.20;
  const total = Math.max(0, subtotal + shippingCost + escrowFee - discount);

  const handleApplyPromo = () => {
    if (promoCode.trim().toUpperCase() === 'BOOKHUB5' || promoCode.trim().length > 0) {
      setDiscount(5.00);
      setPromoApplied(true);
    }
  };

  return (
    <div className="min-h-screen bg-surface text-on-surface pb-32">
      {/* Top App Bar */}
      <header className="sticky top-0 z-30 bg-surface/90 backdrop-blur-md px-4 py-3 border-b border-outline-variant/40 flex items-center justify-between">
        <button
          onClick={() => onNavigate('buyer_home')}
          className="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center text-primary hover:bg-surface-container active:scale-95 transition-all"
        >
          <span className="material-symbols-outlined text-[20px]">arrow_back</span>
        </button>

        <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-bold">
          <span className="material-symbols-outlined text-[15px]">lock</span>
          <span>256-Bit Escrow Encrypted</span>
        </div>

        <button 
          onClick={() => alert('BookHub Escrow Support is available 24/7.')}
          className="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center text-on-surface-variant hover:bg-surface-container"
        >
          <span className="material-symbols-outlined text-[20px]">help_outline</span>
        </button>
      </header>

      {/* Main Container */}
      <main className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* 3-Step Checkout Stepper */}
        <div className="flex items-center justify-between px-2 py-1">
          <div className="flex items-center gap-2">
            <span className="w-6 h-6 rounded-full bg-emerald-600 text-white flex items-center justify-center text-xs font-bold">
              ✓
            </span>
            <span className="text-xs font-bold text-primary">Cart</span>
          </div>
          <div className="h-0.5 flex-1 bg-primary mx-2"></div>
          <div className="flex items-center gap-2">
            <span className="w-6 h-6 rounded-full bg-primary text-white flex items-center justify-center text-xs font-bold">
              2
            </span>
            <span className="text-xs font-bold text-primary">Shipping</span>
          </div>
          <div className="h-0.5 flex-1 bg-outline-variant/40 mx-2"></div>
          <div className="flex items-center gap-2 text-on-surface-variant/70">
            <span className="w-6 h-6 rounded-full bg-surface-container text-on-surface-variant flex items-center justify-center text-xs font-bold">
              3
            </span>
            <span className="text-xs font-medium">Payment</span>
          </div>
        </div>

        {/* Escrow Banner */}
        <div className="p-3 bg-primary text-white rounded-2xl flex items-center gap-3 shadow-xs">
          <span className="material-symbols-outlined text-[24px] text-secondary-container shrink-0">
            verified_user
          </span>
          <p className="text-xs text-white/90 leading-snug">
            <strong>SafeTrade Escrow:</strong> Your funds are held securely until 48 hours after delivery. Full refund guaranteed if condition does not match.
          </p>
        </div>

        {/* Cart Items List */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider">
              Books in Your Cart ({cartItems.reduce((acc, i) => acc + i.quantity, 0)})
            </h3>
            <span className="text-[11px] text-on-surface-variant font-semibold">Inspected Volumes</span>
          </div>

          {cartItems.length === 0 ? (
            <div className="text-center py-6 text-xs text-on-surface-variant">
              Your cart is empty.
              <button
                onClick={() => onNavigate('buyer_home')}
                className="mt-2 block mx-auto text-primary font-bold underline"
              >
                Browse Marketplace
              </button>
            </div>
          ) : (
            <div className="space-y-3">
              {cartItems.map((item) => (
                <div key={item.book.id} className="flex items-start gap-3 pb-3 border-b border-outline-variant/40 last:border-0 last:pb-0">
                  <div className="w-14 h-20 rounded bg-surface-container overflow-hidden shrink-0 book-shadow">
                    <img src={item.book.coverImage} alt={item.book.title} className="w-full h-full object-cover" />
                  </div>

                  <div className="flex-1 min-w-0">
                    <h4 className="font-headline-sm text-xs font-bold text-primary truncate">{item.book.title}</h4>
                    <p className="text-[11px] text-on-surface-variant truncate">{item.book.author}</p>
                    <div className="mt-0.5 flex items-center gap-1 text-[10px] text-emerald-700 font-bold">
                      <span className="material-symbols-outlined text-[12px]">verified</span>
                      <span>Condition: {item.book.condition}</span>
                    </div>

                    <div className="mt-2 flex items-center justify-between">
                      <span className="text-sm font-extrabold text-primary">
                        ${(item.book.price * item.quantity).toFixed(2)}
                      </span>

                      {/* Quantity buttons */}
                      <div className="flex items-center gap-2 bg-surface-container-low rounded-lg p-0.5 border border-outline-variant/60">
                        <button
                          onClick={() => onUpdateQuantity(item.book.id, -1)}
                          className="w-5 h-5 rounded flex items-center justify-center text-primary hover:bg-surface-container active:scale-95 font-bold"
                        >
                          -
                        </button>
                        <span className="text-xs font-bold text-primary px-1">{item.quantity}</span>
                        <button
                          onClick={() => onUpdateQuantity(item.book.id, 1)}
                          className="w-5 h-5 rounded flex items-center justify-center text-primary hover:bg-surface-container active:scale-95 font-bold"
                        >
                          +
                        </button>
                      </div>

                      <button
                        onClick={() => onRemoveItem(item.book.id)}
                        className="text-on-surface-variant hover:text-red-600 transition-colors"
                        title="Remove"
                      >
                        <span className="material-symbols-outlined text-[18px]">delete</span>
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Promo Code Input */}
        <div className="bg-surface-container-lowest rounded-2xl p-3 border border-outline-variant/60 shadow-xs flex items-center gap-2">
          <input
            type="text"
            placeholder="Enter promo code (try BOOKHUB5)"
            value={promoCode}
            onChange={(e) => setPromoCode(e.target.value)}
            className="flex-1 bg-surface-container-low border border-outline-variant rounded-xl px-3 py-2 text-xs font-semibold text-primary outline-hidden uppercase"
          />
          <button
            onClick={handleApplyPromo}
            className="px-4 py-2 bg-primary text-white text-xs font-bold rounded-xl hover:bg-primary-container active:scale-95 transition-all shadow-xs"
          >
            {promoApplied ? 'Applied ✓' : 'Apply'}
          </button>
        </div>

        {/* Delivery Address */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-2">
          <div className="flex items-center justify-between">
            <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[16px] text-primary">location_on</span>
              Delivery Address
            </h3>
            <button className="text-xs font-bold text-secondary-container hover:underline">
              Change
            </button>
          </div>

          <div className="p-3 bg-surface-container-low rounded-xl text-xs">
            <span className="font-bold text-primary block">Alexander Vance (Home)</span>
            <span className="text-on-surface-variant block mt-0.5">142 Livingston St, Apt 4B</span>
            <span className="text-on-surface-variant block">Brooklyn, NY 11201</span>
          </div>
        </div>

        {/* Shipping Method Selection */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-2.5">
          <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider">
            Shipping Method
          </h3>

          <div className="space-y-2">
            <label
              onClick={() => setShippingMethod('standard')}
              className={`p-3 rounded-xl border flex items-center justify-between cursor-pointer transition-all ${
                shippingMethod === 'standard'
                  ? 'bg-primary-fixed/30 border-primary shadow-xs'
                  : 'bg-surface-container-low border-outline-variant'
              }`}
            >
              <div className="flex items-center gap-3">
                <input
                  type="radio"
                  name="shipping"
                  checked={shippingMethod === 'standard'}
                  onChange={() => setShippingMethod('standard')}
                  className="accent-primary"
                />
                <div>
                  <span className="text-xs font-bold text-primary block">Standard Insured Book Post</span>
                  <span className="text-[11px] text-on-surface-variant">Estimated delivery in 3-5 days</span>
                </div>
              </div>
              <span className="text-xs font-extrabold text-primary">$3.99</span>
            </label>

            <label
              onClick={() => setShippingMethod('express')}
              className={`p-3 rounded-xl border flex items-center justify-between cursor-pointer transition-all ${
                shippingMethod === 'express'
                  ? 'bg-primary-fixed/30 border-primary shadow-xs'
                  : 'bg-surface-container-low border-outline-variant'
              }`}
            >
              <div className="flex items-center gap-3">
                <input
                  type="radio"
                  name="shipping"
                  checked={shippingMethod === 'express'}
                  onChange={() => setShippingMethod('express')}
                  className="accent-primary"
                />
                <div>
                  <span className="text-xs font-bold text-primary block">Priority Verified Express</span>
                  <span className="text-[11px] text-on-surface-variant">Estimated delivery in 1-2 days</span>
                </div>
              </div>
              <span className="text-xs font-extrabold text-primary">$7.99</span>
            </label>
          </div>
        </div>

        {/* Payment Method Selector */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-2.5">
          <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider">
            Payment Method
          </h3>

          <div className="grid grid-cols-3 gap-2">
            <button
              onClick={() => setPaymentMethod('apple_pay')}
              className={`p-2.5 rounded-xl border text-center transition-all ${
                paymentMethod === 'apple_pay'
                  ? 'bg-primary text-white shadow-xs border-primary'
                  : 'bg-surface-container-low border-outline-variant text-on-surface'
              }`}
            >
              <span className="material-symbols-outlined text-[20px] block mx-auto">contactless</span>
              <span className="text-[11px] font-bold block mt-1">Apple Pay</span>
            </button>

            <button
              onClick={() => setPaymentMethod('card')}
              className={`p-2.5 rounded-xl border text-center transition-all ${
                paymentMethod === 'card'
                  ? 'bg-primary text-white shadow-xs border-primary'
                  : 'bg-surface-container-low border-outline-variant text-on-surface'
              }`}
            >
              <span className="material-symbols-outlined text-[20px] block mx-auto">credit_card</span>
              <span className="text-[11px] font-bold block mt-1">Card •• 4242</span>
            </button>

            <button
              onClick={() => setPaymentMethod('wallet')}
              className={`p-2.5 rounded-xl border text-center transition-all ${
                paymentMethod === 'wallet'
                  ? 'bg-primary text-white shadow-xs border-primary'
                  : 'bg-surface-container-low border-outline-variant text-on-surface'
              }`}
            >
              <span className="material-symbols-outlined text-[20px] block mx-auto">account_balance_wallet</span>
              <span className="text-[11px] font-bold block mt-1">Escrow Wallet</span>
            </button>
          </div>
        </div>

        {/* Order Cost Breakdown */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-2 text-xs">
          <div className="flex justify-between text-on-surface-variant">
            <span>Books Subtotal</span>
            <span className="font-bold text-primary">${subtotal.toFixed(2)}</span>
          </div>

          <div className="flex justify-between text-on-surface-variant">
            <span>Insured Shipping</span>
            <span className="font-bold text-primary">${shippingCost.toFixed(2)}</span>
          </div>

          <div className="flex justify-between text-on-surface-variant">
            <span>Inspector Authenticity Guarantee</span>
            <span className="font-bold text-emerald-700">FREE</span>
          </div>

          <div className="flex justify-between text-on-surface-variant">
            <span>Escrow Custody Fee</span>
            <span className="font-bold text-primary">${escrowFee.toFixed(2)}</span>
          </div>

          {discount > 0 && (
            <div className="flex justify-between text-emerald-700 font-bold">
              <span>Promo Discount (BOOKHUB5)</span>
              <span>-${discount.toFixed(2)}</span>
            </div>
          )}

          <div className="pt-2 border-t border-outline-variant/50 flex justify-between text-sm font-extrabold text-primary">
            <span>Total Payable with Escrow</span>
            <span>${total.toFixed(2)}</span>
          </div>
        </div>
      </main>

      {/* Sticky Bottom Checkout Dock */}
      <div className="fixed bottom-0 left-0 w-full z-30 bg-surface-container-lowest border-t border-outline-variant/60 px-4 py-3 pb-safe shadow-lg">
        <div className="max-w-md mx-auto flex items-center justify-between gap-3">
          <div>
            <span className="text-[10px] text-on-surface-variant uppercase font-medium block">Total Payable</span>
            <span className="text-lg font-extrabold text-primary">${total.toFixed(2)}</span>
          </div>
          <button
            onClick={() => onPlaceOrder(total)}
            className="flex-1 py-3 px-4 bg-secondary-container hover:bg-secondary-container/90 text-white text-xs font-bold rounded-xl shadow-md transition-all flex items-center justify-center gap-2 active:scale-95"
          >
            <span className="material-symbols-outlined text-[18px]">verified_user</span>
            <span>Place Order & Pay with Escrow</span>
          </button>
        </div>
      </div>
    </div>
  );
};
