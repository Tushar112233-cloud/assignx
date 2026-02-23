import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

/**
 * Test endpoint to verify marketplace_listings table structure and access
 */
export async function GET() {
  const supabase = await createClient();

  console.log("🧪 [Test] Starting marketplace query test");

  try {
    // Test 1: Check authentication
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    console.log("✅ Test 1 - Auth:", { authenticated: !!user, userId: user?.id, error: authError?.message });

    // Test 2: Simple count query (no filters)
    const { count: totalCount, error: countError } = await supabase
      .from("marketplace_listings")
      .select("*", { count: "exact", head: true });

    console.log("✅ Test 2 - Total count:", { count: totalCount, error: countError?.message });

    // Test 3: Query with status='active' filter (FIXED)
    const { count: activeCount, error: activeError } = await supabase
      .from("marketplace_listings")
      .select("*", { count: "exact", head: true })
      .eq("status", "active");

    console.log("✅ Test 3 - Status=active (new way):", { count: activeCount, error: activeError?.message });

    // Test 4: Query with status filter
    const { count: statusCount, error: statusError } = await supabase
      .from("marketplace_listings")
      .select("*", { count: "exact", head: true })
      .eq("status", "active");

    console.log("✅ Test 4 - Status=active count:", { count: statusCount, error: statusError?.message });

    // Test 5: Fetch first 3 listings with minimal fields (FIXED - removed is_active)
    const { data: sampleListings, error: sampleError } = await supabase
      .from("marketplace_listings")
      .select("id, title, seller_id, listing_type, status")
      .limit(3);

    console.log("✅ Test 5 - Sample listings:", {
      count: sampleListings?.length,
      error: sampleError?.message,
      sample: sampleListings
    });

    // Test 6: Full query with joins (like the real query) - FIXED
    const { data: fullQuery, error: fullError } = await supabase
      .from("marketplace_listings")
      .select(`
        *,
        seller:profiles!seller_id (
          id,
          full_name,
          avatar_url
        ),
        category:marketplace_categories (
          id,
          name,
          slug,
          is_active
        ),
        university:universities!university_id(id, name)
      `)
      .eq("status", "active")
      .limit(3);

    console.log("✅ Test 6 - Full query:", {
      count: fullQuery?.length,
      error: fullError?.message,
      errorDetails: fullError,
    });

    // Return results
    return NextResponse.json({
      success: true,
      timestamp: new Date().toISOString(),
      tests: {
        auth: {
          passed: !!user,
          userId: user?.id,
          error: authError?.message,
        },
        totalCount: {
          passed: !countError,
          count: totalCount,
          error: countError?.message,
        },
        activeCount: {
          passed: !activeError,
          count: activeCount,
          error: activeError?.message,
        },
        statusCount: {
          passed: !statusError,
          count: statusCount,
          error: statusError?.message,
        },
        sampleListings: {
          passed: !sampleError,
          count: sampleListings?.length,
          listings: sampleListings,
          error: sampleError?.message,
        },
        fullQuery: {
          passed: !fullError,
          count: fullQuery?.length,
          error: fullError?.message,
          errorCode: fullError?.code,
          errorDetails: fullError?.details,
          errorHint: fullError?.hint,
        },
      },
    });
  } catch (error: any) {
    console.error("💥 [Test] Unexpected error:", error);
    return NextResponse.json({
      success: false,
      error: error.message,
      stack: error.stack,
    }, { status: 500 });
  }
}
