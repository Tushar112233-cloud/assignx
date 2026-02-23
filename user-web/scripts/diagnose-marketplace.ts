/**
 * Marketplace Diagnostic Script
 * Checks database state to diagnose marketplace loading issues
 */

import { createClient } from "@/lib/supabase/server";

async function diagnoseMarketplace() {
  console.log("🔍 Starting Marketplace Diagnostics...\n");

  const supabase = await createClient();

  // 1. Check authentication
  console.log("1️⃣ Checking Authentication...");
  const { data: { user }, error: authError } = await supabase.auth.getUser();

  if (authError || !user) {
    console.error("❌ Not authenticated:", authError?.message);
    return;
  }
  console.log("✅ User authenticated:", user.email);
  console.log("   User ID:", user.id, "\n");

  // 2. Check user profile
  console.log("2️⃣ Checking User Profile...");
  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  if (profileError) {
    console.error("❌ Profile error:", profileError.message);
  } else {
    console.log("✅ Profile found");
    console.log("   Name:", profile.full_name);
    console.log("   User Type:", profile.user_type || "NOT SET");
  }
  console.log("");

  // 3. Check student profile (for university_id)
  console.log("3️⃣ Checking Student Profile...");
  const { data: studentProfile, error: studentError } = await supabase
    .from("students")
    .select("university_id, universities(name)")
    .eq("profile_id", user.id)
    .single();

  if (studentError) {
    console.warn("⚠️  No student profile found");
    console.log("   This means universityOnly filter won't work!");
    console.log("   Error:", studentError.message);
  } else if (!studentProfile?.university_id) {
    console.warn("⚠️  Student profile exists but no university_id set");
  } else {
    console.log("✅ Student profile found");
    console.log("   University ID:", studentProfile.university_id);
    console.log("   University:", (studentProfile.universities as any)?.name);
  }
  console.log("");

  // 4. Check total marketplace listings
  console.log("4️⃣ Checking Marketplace Listings...");
  const { count: totalCount, error: countError } = await supabase
    .from("marketplace_listings")
    .select("*", { count: "exact", head: true })
    .eq("is_active", true);

  if (countError) {
    console.error("❌ Error counting listings:", countError.message);
  } else {
    console.log(`📊 Total active listings: ${totalCount || 0}`);
  }

  // 5. Check listings by university (if user has university_id)
  if (studentProfile?.university_id) {
    console.log("\n5️⃣ Checking Listings for Your University...");
    const { count: uniCount, error: uniError } = await supabase
      .from("marketplace_listings")
      .select("*", { count: "exact", head: true })
      .eq("is_active", true)
      .eq("university_id", studentProfile.university_id);

    if (uniError) {
      console.error("❌ Error:", uniError.message);
    } else {
      console.log(`🎓 Listings for your university: ${uniCount || 0}`);

      if (uniCount === 0) {
        console.warn("⚠️  NO LISTINGS for your university!");
        console.log("   Recommendation: Set universityOnly to FALSE by default");
      }
    }
  }

  // 6. Sample listings (first 5)
  console.log("\n6️⃣ Sample Listings...");
  const { data: sampleListings, error: sampleError } = await supabase
    .from("marketplace_listings")
    .select(`
      id,
      title,
      listing_type,
      price,
      university_id,
      seller:profiles!seller_id(full_name),
      university:universities!university_id(name)
    `)
    .eq("is_active", true)
    .limit(5);

  if (sampleError) {
    console.error("❌ Error fetching samples:", sampleError.message);
  } else if (!sampleListings || sampleListings.length === 0) {
    console.error("❌ NO LISTINGS FOUND IN DATABASE!");
    console.log("\n💡 Solutions:");
    console.log("   1. Create sample listings in Supabase dashboard");
    console.log("   2. Use the /connect/create page to post listings");
    console.log("   3. Import seed data");
  } else {
    console.log(`✅ Found ${sampleListings.length} sample listings:`);
    sampleListings.forEach((listing, i) => {
      console.log(`\n   ${i + 1}. ${listing.title}`);
      console.log(`      Type: ${listing.listing_type}`);
      console.log(`      Price: ${listing.price || 'N/A'}`);
      console.log(`      University: ${(listing.university as any)?.name || 'None'}`);
      console.log(`      Seller: ${(listing.seller as any)?.full_name || 'Unknown'}`);
    });
  }

  // 7. Check marketplace categories
  console.log("\n\n7️⃣ Checking Marketplace Categories...");
  const { data: categories, error: catError } = await supabase
    .from("marketplace_categories")
    .select("name, slug, is_active")
    .eq("is_active", true);

  if (catError) {
    console.error("❌ Error:", catError.message);
  } else {
    console.log(`📁 Active categories: ${categories?.length || 0}`);
    categories?.forEach(cat => {
      console.log(`   - ${cat.name} (${cat.slug})`);
    });
  }

  // Summary and recommendations
  console.log("\n\n" + "=".repeat(60));
  console.log("📋 SUMMARY & RECOMMENDATIONS");
  console.log("=".repeat(60));

  if (!studentProfile?.university_id) {
    console.log("\n⚠️  ISSUE: User has no university_id");
    console.log("   Impact: universityOnly filter returns empty results");
    console.log("   Fix: Change default to universityOnly: false");
  }

  if (totalCount === 0) {
    console.log("\n❌ CRITICAL: Database has NO listings");
    console.log("   Fix: Add sample data to marketplace_listings table");
  } else if (studentProfile?.university_id) {
    const { count: uniCount } = await supabase
      .from("marketplace_listings")
      .select("*", { count: "exact", head: true })
      .eq("is_active", true)
      .eq("university_id", studentProfile.university_id);

    if (uniCount === 0) {
      console.log("\n⚠️  ISSUE: No listings for user's university");
      console.log("   Fix: Change default to universityOnly: false");
    }
  }

  console.log("\n✅ Diagnostic complete!\n");
}

// Run diagnostics
diagnoseMarketplace().catch(console.error);
