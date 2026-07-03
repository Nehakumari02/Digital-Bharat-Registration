<?php
/**
 * Copy into your Laravel app, e.g. app/Http/Controllers/Api/ValidatePartnerCodeController.php
 *
 * routes/api.php:
 *   Route::post('/validate-partner-code', [ValidatePartnerCodeController::class, 'validate']);
 *   Route::get('/validate-partner-code/{code}', [ValidatePartnerCodeController::class, 'validateGet']);
 *
 * users table needs: partner_code (string, unique, nullable), registration_type, wallet_balance
 */
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class ValidatePartnerCodeController extends Controller
{
    public function validate(Request $request)
    {
        $code = $this->normalizeCode(
            $request->input('partner_code')
            ?? $request->input('code')
            ?? $request->input('referral_code')
        );

        if ($code === '') {
            return response()->json(['valid' => false, 'message' => 'Partner code required'], 422);
        }

        return $this->lookup($code);
    }

    public function validateGet(string $code)
    {
        return $this->lookup($this->normalizeCode($code));
    }

    private function lookup(string $code)
    {
        $partner = User::query()
            ->where('partner_code', $code)
            ->where(function ($q) {
                $q->where('registration_type', 'partner')
                    ->orWhere('is_partner', true);
            })
            ->first();

        if (!$partner) {
            return response()->json([
                'valid' => false,
                'message' => 'Partner code not found',
            ], 200);
        }

        return response()->json([
            'valid' => true,
            'partner_name' => $partner->name,
            'partner_id' => $partner->id,
        ]);
    }

    private function normalizeCode(?string $raw): string
    {
        $s = strtoupper(trim((string) $raw));
        if ($s === '') {
            return '';
        }
        if (!str_starts_with($s, 'PRT-')) {
            $s = 'PRT-' . ltrim($s, 'PRT-');
        }
        return $s;
    }
}
