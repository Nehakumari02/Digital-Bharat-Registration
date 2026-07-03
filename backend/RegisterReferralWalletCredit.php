<?php

/**
 * Add to your Laravel Register controller after creating the new user.
 *
 * When request includes referred_partner_code (normal ₹599 signup):
 * - Find partner user by partner_code
 * - Add referral_cashback_amount (default 59.90) to wallet_balance
 * - Optionally insert wallet_transactions row
 */

namespace App\Http\Controllers\Api;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Http\Request;

trait RegisterReferralWalletCredit
{
    protected function creditPartnerReferralWallet(Request $request, ?User $newUser = null): ?float
    {
        $code = strtoupper(trim((string) $request->input('referred_partner_code', $request->input('referral_code', ''))));
        if ($code === '' || ! str_starts_with($code, 'PRT-')) {
            return null;
        }

        $partner = User::query()
            ->where('partner_code', $code)
            ->orWhere('referral_code', $code)
            ->first();

        if (! $partner) {
            return null;
        }

        $amount = (float) $request->input('referral_cashback_amount', 59.90);
        if ($amount <= 0) {
            $amount = round(599 * 0.10, 2);
        }

        DB::transaction(function () use ($partner, $amount, $code, $newUser) {
            $partner->wallet_balance = (float) ($partner->wallet_balance ?? 0) + $amount;
            $partner->save();

            // Optional but recommended: keep a transaction ledger.
            // If table doesn't exist yet, wallet balance update still succeeds.
            if (Schema::hasTable('partner_wallet_transactions')) {
                DB::table('partner_wallet_transactions')->insert([
                    'partner_user_id' => $partner->id,
                    'partner_code' => $code,
                    'referee_user_id' => $newUser?->id,
                    'amount' => $amount,
                    'source' => 'registration_referral',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        });

        return $amount;
    }
}
