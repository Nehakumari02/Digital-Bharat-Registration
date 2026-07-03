## Backend Integration Steps (Laravel)

Use these files from this repo:

- `backend/RegisterReferralWalletCredit.php`
- `backend/PartnerWalletRoutes.php` (contains `PartnerWalletController`)
- `backend/ValidatePartnerCodeController.php`
- `backend/WalletBackendMigrations.php` (migration template)

### 1) Add/Run Migrations

Create real migration files in your Laravel backend using `WalletBackendMigrations.php` as reference, then run:

```bash
php artisan migrate
```

### 2) Register API routes (`routes/api.php`)

```php
use App\Http\Controllers\Api\PartnerWalletController;
use App\Http\Controllers\Api\ValidatePartnerCodeController;
use App\Http\Controllers\Api\RegisterController; // your register controller

Route::post('/register', [RegisterController::class, 'register']);
Route::post('/validate-partner-code', [ValidatePartnerCodeController::class, 'validate']);
Route::get('/validate-partner-code/{code}', [ValidatePartnerCodeController::class, 'validateGet']);
Route::get('/partner-wallet', [PartnerWalletController::class, 'show']);
Route::post('/partner-wallet/credit', [PartnerWalletController::class, 'credit']);
```

### 3) Hook referral credit in RegisterController

Inside your register controller:

```php
use App\Http\Controllers\Api\RegisterReferralWalletCredit;

class RegisterController extends Controller
{
    use RegisterReferralWalletCredit;

    public function register(Request $request)
    {
        // create user first...
        $user = User::create([...]);

        $credited = $this->creditPartnerReferralWallet($request, $user);

        return response()->json([
            'success' => true,
            'user' => $user->fresh(),
            'cashback_credited' => $credited,
            'wallet_balance' => (float) ($user->wallet_balance ?? 0),
        ]);
    }
}
```

### 4) Return fields on login

Ensure login response includes:

- `id`
- `registration_type`
- `is_partner`
- `partner_code`
- `wallet_balance`

### 5) Verify

1. Register partner (₹5999) -> confirm `users.partner_code` exists.
2. Register normal with `referred_partner_code` -> confirm partner `wallet_balance` increases by `59.90`.
3. Open Flutter wallet screen -> `api` value in logs should be > `0` and stable on refresh.

