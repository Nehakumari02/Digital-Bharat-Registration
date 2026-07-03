<?php

/**
 * Laravel CORS for Flutter web → http://127.0.0.1:8000
 *
 * 1. Publish config: php artisan config:publish cors
 *    OR merge into config/cors.php:
 */
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];

/**
 * 2. Ensure bootstrap/app.php or Http/Kernel uses HandleCors middleware.
 *
 * 3. For local dev, run API with:
 *    php artisan serve
 *
 * 4. Flutter web must use the same host you allow, e.g. http://127.0.0.1:8000/api
 */
