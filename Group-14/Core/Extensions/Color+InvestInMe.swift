//
//  Color+InvestInMe.swift
//  Group-14
//
//  InvestInMe brand color palette — centralized so all views stay consistent.
//  Hex values traced from `investinme_full_ui.html`.
//

import SwiftUI

private extension Color {
    /// Build a Color from a packed 24-bit hex literal, e.g. `0xD4537E`.
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension Color {
    // MARK: - InvestInMe primary palette

    /// Primary brand pink — used on CTAs, key icons, selected tab.
    static let investPrimary       = Color(hex: 0xD4537E)
    /// Secondary wine — used for hover/pressed states and emphasis text.
    static let investAccent        = Color(hex: 0x993556)
    /// Warm coral for legacy CTAs (kept for backwards compatibility).
    static let investCoral         = Color(hex: 0xD4537E)
    /// Dark wine reserved for hero titles and section headings.
    static let investTitle         = Color(hex: 0x4B1528)

    // MARK: - Surfaces

    /// Scroll background — slightly off-white so cards pop.
    static let investBackground    = Color(hex: 0xF9F9F9)
    /// Card and sheet surface.
    static let investSurface       = Color.white
    /// Alternate card tone (same as surface for now; kept as a token for
    /// future depth layering).
    static let investCard          = Color.white
    /// Light pink hero band behind brand titles.
    static let investHeroBand      = Color(hex: 0xFBEAF0)
    /// Border / divider stroke on pink-themed surfaces.
    static let investBorder        = Color(hex: 0xF4C0D1)

    // MARK: - Text

    static let investTextPrimary   = Color(hex: 0x1A1A1A)
    static let investTextSecondary = Color(hex: 0x999999)

    // MARK: - Track badges (Financial / Tech)

    /// Green for Financial track badges.
    static let trackFinancial      = Color(hex: 0x0F6E56)
    /// Soft green background pairing for Financial badges.
    static let trackFinancialBg    = Color(hex: 0xE1F5EE)
    /// Purple for Tech track badges.
    static let trackTech           = Color(hex: 0x534AB7)
    /// Soft purple background pairing for Tech badges.
    static let trackTechBg         = Color(hex: 0xEEEDFE)

    // MARK: - Confidence gradient stops (semantic, not brand)

    static let confidenceLow       = Color(hue: 0.03, saturation: 0.80, brightness: 0.85)  // coral
    static let confidenceMid       = Color(hue: 0.13, saturation: 0.85, brightness: 0.95)  // amber
    static let confidenceHigh      = Color(hue: 0.40, saturation: 0.75, brightness: 0.80)  // green

    // MARK: - Back-compat aliases
    //
    // The codebase originally used `ascend*` tokens against a dark indigo
    // palette. Pointing the old names at the new InvestInMe values lets every
    // existing view pick up the rebrand without a sweeping search-and-replace.
    // New code should prefer the `invest*` tokens above.

    static let ascendPrimary        = investPrimary
    static let ascendAccent         = investPrimary
    static let ascendCoral          = investCoral
    static let ascendBackground     = investBackground
    static let ascendSurface        = investSurface
    static let ascendCard           = investCard
    static let ascendTextPrimary    = investTextPrimary
    static let ascendTextSecondary  = investTextSecondary
}
