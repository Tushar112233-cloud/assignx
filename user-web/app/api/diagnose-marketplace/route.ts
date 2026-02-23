import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function GET() {
  const diagnostics: any = {
    timestamp: new Date().toISOString(),
    checks: [],
  };

  try {
    const supabase = await createClient();

    // 1. Check authentication
    const { data: { user }, error: authError } = await supabase.auth.getUser();

    diagnostics.checks.push({
      name: "Authentication",
      status: user ? "✅ OK" : "❌ FAILED",
      details: {
        authenticated: !!user,
        userId: user?.id,
        email: user?.email,
        error: authError?.message,
      },
    });

    if (!user) {
      return NextResponse.json(diagnostics);
    }

    // 2. Check user profile
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    diagnostics.checks.push({
      name: "User Profile",
      status: profile ? "✅ OK" : "❌ FAILED",
      details: {
        found: !!profile,
        fullName: profile?.full_name,
        userType: profile?.user_type || "NOT SET",
        error: profileError?.message,
      },
    });

    // 3. Check student profile
    const { data: studentProfile, error: studentError } = await supabase
      .from("students")
      .select("university_id, universities(name)")
      .eq("profile_id", user.id)
      .single();

    diagnostics.checks.push({
      name: "Student Profile",
      status: studentProfile?.university_id ? "✅ OK" : "⚠️ WARNING",
      details: {
        found: !!studentProfile,
        hasUniversityId: !!studentProfile?.university_id,
        universityId: studentProfile?.university_id,
        universityName: (studentProfile?.universities as any)?.name,
        error: studentError?.message,
        warning: !studentProfile?.university_id
          ? "No university_id - universityOnly filter will not work"
          : null,
      },
    });

    // 4. Check total listings
    const { count: totalCount, error: totalError } = await supabase
      .from("marketplace_listings")
      .select("*", { count: "exact", head: true })
      .eq("is_active", true);

    diagnostics.checks.push({
      name: "Total Marketplace Listings",
      status: (totalCount || 0) > 0 ? "✅ OK" : "❌ EMPTY",
      details: {
        totalListings: totalCount || 0,
        error: totalError?.message,
      },
    });

    // 5. Check university-specific listings
    if (studentProfile?.university_id) {
      const { count: uniCount, error: uniError } = await supabase
        .from("marketplace_listings")
        .select("*", { count: "exact", head: true })
        .eq("is_active", true)
        .eq("university_id", studentProfile.university_id);

      diagnostics.checks.push({
        name: "University-Specific Listings",
        status: (uniCount || 0) > 0 ? "✅ OK" : "⚠️ EMPTY",
        details: {
          universityListings: uniCount || 0,
          error: uniError?.message,
          warning:
            (uniCount || 0) === 0
              ? "No listings for your university - universityOnly filter will show empty results"
              : null,
        },
      });
    }

    // 6. Get sample listings
    const { data: sampleListings, error: sampleError } = await supabase
      .from("marketplace_listings")
      .select(`
        id,
        title,
        listing_type,
        price,
        university_id,
        is_active,
        seller:profiles!seller_id(full_name),
        university:universities!university_id(name)
      `)
      .eq("is_active", true)
      .limit(5);

    diagnostics.checks.push({
      name: "Sample Listings",
      status: (sampleListings?.length || 0) > 0 ? "✅ OK" : "❌ EMPTY",
      details: {
        count: sampleListings?.length || 0,
        samples: sampleListings?.map((l) => ({
          id: l.id,
          title: l.title,
          type: l.listing_type,
          price: l.price,
          university: (l.university as any)?.name || "None",
          seller: (l.seller as any)?.full_name || "Unknown",
        })),
        error: sampleError?.message,
      },
    });

    // 7. Check categories
    const { data: categories, error: catError } = await supabase
      .from("marketplace_categories")
      .select("name, slug, is_active")
      .eq("is_active", true);

    diagnostics.checks.push({
      name: "Marketplace Categories",
      status: (categories?.length || 0) > 0 ? "✅ OK" : "⚠️ EMPTY",
      details: {
        count: categories?.length || 0,
        categories: categories?.map((c) => ({ name: c.name, slug: c.slug })),
        error: catError?.message,
      },
    });

    // 8. Test the actual query used by the page
    const { data: testQuery, error: testError } = await supabase
      .from("marketplace_listings")
      .select(`
        *,
        seller:profiles!seller_id (id, full_name, avatar_url),
        category:marketplace_categories (id, name, slug, is_active),
        university:universities!university_id(id, name)
      `)
      .eq("is_active", true)
      .eq(
        "university_id",
        studentProfile?.university_id || "00000000-0000-0000-0000-000000000000"
      );

    diagnostics.checks.push({
      name: "Actual Page Query (with universityOnly=true)",
      status: (testQuery?.length || 0) > 0 ? "✅ OK" : "❌ EMPTY",
      details: {
        resultsCount: testQuery?.length || 0,
        queryUniversityId: studentProfile?.university_id,
        error: testError?.message,
        warning:
          (testQuery?.length || 0) === 0
            ? "This is WHY the marketplace shows empty! Change universityOnly default to false."
            : null,
      },
    });

    // Generate recommendations
    const recommendations: string[] = [];

    if (!studentProfile?.university_id) {
      recommendations.push(
        "❗ User has no university_id - set universityOnly to FALSE by default"
      );
    }

    if ((totalCount || 0) === 0) {
      recommendations.push(
        "❗ Database has NO listings - add sample data or create listings"
      );
    } else if (studentProfile?.university_id) {
      const { count: uniCount } = await supabase
        .from("marketplace_listings")
        .select("*", { count: "exact", head: true })
        .eq("is_active", true)
        .eq("university_id", studentProfile.university_id);

      if ((uniCount || 0) === 0) {
        recommendations.push(
          "❗ No listings for user's university - set universityOnly to FALSE by default"
        );
      }
    }

    diagnostics.recommendations = recommendations;
    diagnostics.summary = {
      totalIssues: diagnostics.checks.filter((c: any) =>
        c.status.includes("❌")
      ).length,
      totalWarnings: diagnostics.checks.filter((c: any) =>
        c.status.includes("⚠️")
      ).length,
      totalOk: diagnostics.checks.filter((c: any) => c.status.includes("✅"))
        .length,
    };

    return NextResponse.json(diagnostics, { status: 200 });
  } catch (error: any) {
    return NextResponse.json(
      {
        error: error.message,
        diagnostics,
      },
      { status: 500 }
    );
  }
}
