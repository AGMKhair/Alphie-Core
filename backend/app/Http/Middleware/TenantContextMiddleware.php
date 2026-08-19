<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class TenantContextMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $orgId = $request->header('X-Organization-Id');
        $branchId = $request->header('X-Branch-Id');

        // Allow Super Admin endpoints to bypass tenant requirement
        if (!$orgId && $request->is('api/v1/super-admin/*')) {
            return $next($request);
        }

        // Attach resolved tenant info to the request attributes
        $request->attributes->set('tenant_org_id', $orgId ? (int)$orgId : null);
        $request->attributes->set('tenant_branch_id', $branchId ? (int)$branchId : null);

        $response = $next($request);

        // Echo active tenant headers in response for cross-verification
        if ($orgId) {
            $response->headers->set('X-Active-Tenant', $orgId);
        }

        return $response;
    }
}
