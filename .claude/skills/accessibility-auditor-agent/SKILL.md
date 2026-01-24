---
name: accessibility-auditor-agent
description: Comprehensive accessibility audit agent that performs systematic WCAG 2.1 AA compliance assessments, screen reader testing, keyboard navigation validation, and color contrast analysis. Provides detailed remediation guidance and accessibility best practices. Use for accessibility audits, compliance verification, or building inclusive applications.
---

# Accessibility Auditor Agent

A systematic, comprehensive accessibility audit methodology that replicates the capabilities of a senior accessibility specialist. This agent conducts thorough WCAG 2.1 AA compliance assessments covering perceivable, operable, understandable, and robust principles with detailed remediation guidance.

## Activation Triggers

Invoke this agent when:
- Conducting accessibility audits
- Verifying WCAG compliance
- Testing with assistive technologies
- Building accessible components
- Remediating accessibility issues
- Establishing accessibility standards
- Keywords: accessibility, a11y, WCAG, screen reader, keyboard navigation, ARIA, color contrast, ADA, Section 508

## Agent Methodology

### Phase 1: Audit Scope Definition

Before beginning the audit, establish the scope and context:

```markdown
## Accessibility Audit Context

### Compliance Target
- [ ] WCAG 2.1 Level A
- [ ] WCAG 2.1 Level AA (most common requirement)
- [ ] WCAG 2.1 Level AAA
- [ ] Section 508 (U.S. federal)
- [ ] EN 301 549 (European)
- [ ] AODA (Ontario, Canada)

### Audit Scope
- [ ] Full site/application audit
- [ ] Specific pages/components
- [ ] New feature review
- [ ] Remediation verification

### User Personas
Consider users with:
- [ ] Visual impairments (blind, low vision, color blindness)
- [ ] Hearing impairments (deaf, hard of hearing)
- [ ] Motor impairments (limited mobility, tremors)
- [ ] Cognitive impairments (learning disabilities, attention deficits)
- [ ] Temporary impairments (broken arm, migraine)
- [ ] Situational limitations (bright sunlight, noisy environment)

### Testing Environment
- [ ] Screen readers (NVDA, JAWS, VoiceOver)
- [ ] Keyboard-only navigation
- [ ] Screen magnification
- [ ] High contrast mode
- [ ] Reduced motion settings
- [ ] Mobile accessibility features
```

### Phase 2: WCAG 2.1 Comprehensive Audit

#### Principle 1: Perceivable

```markdown
## 1.1 Text Alternatives

### 1.1.1 Non-text Content (Level A)

**Audit Checklist:**
- [ ] All images have appropriate alt text
- [ ] Decorative images have empty alt (`alt=""`)
- [ ] Complex images have extended descriptions
- [ ] Form inputs have accessible labels
- [ ] Icons have text alternatives
- [ ] CAPTCHA has alternatives
- [ ] Audio/video has text alternatives

**Testing Procedure:**
```javascript
// Find images without alt text
document.querySelectorAll('img:not([alt])');

// Find images with empty alt that appear informative
document.querySelectorAll('img[alt=""]').forEach(img => {
  console.log(img.src, img.parentElement.textContent);
});

// Check icon buttons
document.querySelectorAll('button, [role="button"]').forEach(btn => {
  if (!btn.textContent.trim() && !btn.getAttribute('aria-label')) {
    console.log('Missing accessible name:', btn);
  }
});
```

**Common Issues and Fixes:**

```html
<!-- BAD: Missing alt text -->
<img src="product.jpg">

<!-- GOOD: Descriptive alt text -->
<img src="product.jpg" alt="Red leather handbag with gold buckle">

<!-- BAD: Meaningless alt text -->
<img src="chart.png" alt="image">

<!-- GOOD: Descriptive for informative images -->
<img src="chart.png" alt="Sales increased 25% from Q1 to Q2 2024">

<!-- GOOD: Empty alt for decorative images -->
<img src="decorative-border.png" alt="" role="presentation">

<!-- BAD: Icon button without accessible name -->
<button><svg>...</svg></button>

<!-- GOOD: Icon button with accessible name -->
<button aria-label="Close dialog"><svg aria-hidden="true">...</svg></button>
```

## 1.2 Time-based Media

### 1.2.1 Audio-only and Video-only (Level A)
### 1.2.2 Captions (Level A)
### 1.2.3 Audio Description (Level A)
### 1.2.5 Audio Description (Level AA)

**Audit Checklist:**
- [ ] Pre-recorded audio has transcripts
- [ ] Pre-recorded video has captions
- [ ] Pre-recorded video has audio descriptions
- [ ] Captions are synchronized
- [ ] Captions include speaker identification
- [ ] Captions include relevant sound effects

**Remediation:**

```html
<!-- Video with captions and descriptions -->
<video controls>
  <source src="video.mp4" type="video/mp4">
  <track kind="captions" src="captions.vtt" srclang="en" label="English">
  <track kind="descriptions" src="descriptions.vtt" srclang="en" label="Audio Descriptions">
</video>

<!-- Example VTT caption file -->
WEBVTT

00:00:00.000 --> 00:00:03.000
[Upbeat music playing]

00:00:03.000 --> 00:00:06.000
SARAH: Welcome to our product demo.

00:00:06.000 --> 00:00:10.000
[Screen shows dashboard interface]
```

## 1.3 Adaptable

### 1.3.1 Info and Relationships (Level A)

**Audit Checklist:**
- [ ] Headings use proper heading elements (h1-h6)
- [ ] Heading hierarchy is logical
- [ ] Lists use proper list elements
- [ ] Tables have proper headers
- [ ] Form labels are programmatically associated
- [ ] Regions use landmarks or ARIA roles

**Testing with Screen Reader:**
```bash
# NVDA heading navigation
Press H - Next heading
Press 1-6 - Next heading of that level
Press Insert+F7 - Elements list

# VoiceOver
Press VO+Command+H - Next heading
Press VO+U - Rotor (navigate by landmarks, headings, etc.)
```

**Common Issues and Fixes:**

```html
<!-- BAD: Visual-only heading -->
<p class="heading-style">Section Title</p>

<!-- GOOD: Semantic heading -->
<h2>Section Title</h2>

<!-- BAD: Table without headers -->
<table>
  <tr><td>Name</td><td>Age</td></tr>
  <tr><td>John</td><td>25</td></tr>
</table>

<!-- GOOD: Table with proper headers -->
<table>
  <caption>User Information</caption>
  <thead>
    <tr>
      <th scope="col">Name</th>
      <th scope="col">Age</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>John</td>
      <td>25</td>
    </tr>
  </tbody>
</table>

<!-- BAD: Unlabeled form input -->
<input type="text" placeholder="Enter email">

<!-- GOOD: Labeled form input -->
<label for="email">Email address</label>
<input type="email" id="email" autocomplete="email">
```

### 1.3.2 Meaningful Sequence (Level A)

**Testing:**
```javascript
// Check if visual order matches DOM order
// View page with CSS disabled
// Tab through page and verify logical order
```

### 1.3.3 Sensory Characteristics (Level A)

**Audit Checklist:**
- [ ] Instructions don't rely solely on shape, color, size, location
- [ ] Error messages don't say "the red field"
- [ ] Instructions don't say "click the button on the right"

```html
<!-- BAD: Relies on color alone -->
<p>Required fields are in red.</p>

<!-- GOOD: Multiple indicators -->
<p>Required fields are marked with an asterisk (*).</p>

<!-- BAD: Relies on position -->
<p>Click the button on the right to continue.</p>

<!-- GOOD: Explicit reference -->
<p>Click the "Continue" button to proceed.</p>
```

### 1.3.4 Orientation (Level AA)

- [ ] Content not restricted to single orientation
- [ ] Portrait/landscape both supported

### 1.3.5 Identify Input Purpose (Level AA)

```html
<!-- Use autocomplete for common inputs -->
<input type="email" autocomplete="email">
<input type="tel" autocomplete="tel">
<input type="text" autocomplete="given-name">
<input type="text" autocomplete="family-name">
<input type="text" autocomplete="street-address">
```

## 1.4 Distinguishable

### 1.4.1 Use of Color (Level A)

**Audit Checklist:**
- [ ] Color is not only means of conveying information
- [ ] Links distinguished by more than color
- [ ] Charts/graphs use patterns or labels

```html
<!-- BAD: Link only distinguished by color -->
<p>Visit our <span style="color: blue;">homepage</span></p>

<!-- GOOD: Link with underline -->
<p>Visit our <a href="/">homepage</a></p>

<!-- GOOD: Form errors with icon + color + text -->
<div class="error" role="alert">
  <svg aria-hidden="true"><!-- error icon --></svg>
  <span>Email address is invalid</span>
</div>
```

### 1.4.3 Contrast (Minimum) (Level AA)

**Requirements:**
- Normal text: 4.5:1 contrast ratio
- Large text (18pt+, or 14pt bold): 3:1 contrast ratio
- UI components and graphical objects: 3:1 contrast ratio

**Testing Tools:**
```bash
# Browser DevTools
# Chrome: Inspect element > Styles > Color > Contrast ratio

# Command line
npx axe-cli https://example.com

# WebAIM Contrast Checker
# https://webaim.org/resources/contrastchecker/
```

**Common Fixes:**
```css
/* BAD: Low contrast */
.text-gray {
  color: #999999; /* Only 2.8:1 against white */
}

/* GOOD: Sufficient contrast */
.text-gray {
  color: #767676; /* 4.5:1 against white */
}

/* Focus states need sufficient contrast too */
button:focus {
  outline: 2px solid #005fcc; /* Visible against background */
  outline-offset: 2px;
}
```

### 1.4.4 Resize Text (Level AA)

- [ ] Text can be resized to 200% without loss of functionality
- [ ] No horizontal scrolling at 200% zoom

### 1.4.10 Reflow (Level AA)

- [ ] Content reflows at 400% zoom (320px width)
- [ ] No horizontal scrolling (except data tables, images, toolbars)

```css
/* Responsive design for reflow */
.content {
  max-width: 100%;
  overflow-wrap: break-word;
}

/* Avoid fixed widths */
.container {
  width: 100%; /* Not: width: 1200px */
  max-width: 1200px;
}
```

### 1.4.11 Non-text Contrast (Level AA)

- [ ] UI components have 3:1 contrast
- [ ] Focus indicators have 3:1 contrast
- [ ] Graphical objects have 3:1 contrast

### 1.4.12 Text Spacing (Level AA)

Content must be readable with:
- Line height: 1.5x font size
- Paragraph spacing: 2x font size
- Letter spacing: 0.12x font size
- Word spacing: 0.16x font size

```javascript
// Test bookmarklet
javascript:(function(){
  var style = document.createElement('style');
  style.textContent = '* { line-height: 1.5 !important; letter-spacing: 0.12em !important; word-spacing: 0.16em !important; } p { margin-bottom: 2em !important; }';
  document.head.appendChild(style);
})();
```

### 1.4.13 Content on Hover or Focus (Level AA)

Hover/focus content must be:
- Dismissible (Escape key)
- Hoverable (can move pointer to it)
- Persistent (stays until dismissed)

```css
/* Tooltip that meets requirements */
.tooltip-trigger:hover + .tooltip,
.tooltip-trigger:focus + .tooltip,
.tooltip:hover {
  display: block;
}

.tooltip {
  display: none;
  position: absolute;
  /* Hoverable: positioned so user can reach it */
}
```

```javascript
// Dismissible with Escape
tooltip.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    hideTooltip();
  }
});
```
```

#### Principle 2: Operable

```markdown
## 2.1 Keyboard Accessible

### 2.1.1 Keyboard (Level A)

**Audit Checklist:**
- [ ] All functionality available via keyboard
- [ ] No keyboard traps
- [ ] Tab order is logical
- [ ] Focus is visible at all times
- [ ] Custom widgets have keyboard support

**Testing Procedure:**
1. Disconnect/disable mouse
2. Tab through entire page
3. Verify all interactive elements are reachable
4. Verify all actions can be performed
5. Verify you can always escape/navigate away

**Keyboard Support for Custom Widgets:**

```javascript
// Custom dropdown keyboard support
dropdown.addEventListener('keydown', (e) => {
  switch (e.key) {
    case 'ArrowDown':
      e.preventDefault();
      focusNextOption();
      break;
    case 'ArrowUp':
      e.preventDefault();
      focusPreviousOption();
      break;
    case 'Enter':
    case ' ':
      e.preventDefault();
      selectCurrentOption();
      break;
    case 'Escape':
      closeDropdown();
      break;
    case 'Home':
      e.preventDefault();
      focusFirstOption();
      break;
    case 'End':
      e.preventDefault();
      focusLastOption();
      break;
  }
});
```

### 2.1.2 No Keyboard Trap (Level A)

**Testing:**
- Verify Tab and Shift+Tab can always navigate away
- Modal dialogs should trap focus BUT allow Escape to exit

```javascript
// Proper focus trap for modals
function trapFocus(modal) {
  const focusables = modal.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  const first = focusables[0];
  const last = focusables[focusables.length - 1];

  modal.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }
    if (e.key === 'Escape') {
      closeModal();
    }
  });
}
```

### 2.1.4 Character Key Shortcuts (Level A)

- [ ] Single character shortcuts can be remapped or disabled
- [ ] Or only active when component has focus

## 2.2 Enough Time

### 2.2.1 Timing Adjustable (Level A)

If time limits exist:
- [ ] User can turn off time limit
- [ ] User can adjust time limit
- [ ] User can extend time (at least 10x)
- [ ] Or time limit is 20+ hours

### 2.2.2 Pause, Stop, Hide (Level A)

- [ ] Auto-updating content can be paused
- [ ] Auto-scrolling can be stopped
- [ ] Animations can be disabled

```css
/* Respect reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

## 2.3 Seizures and Physical Reactions

### 2.3.1 Three Flashes or Below Threshold (Level A)

- [ ] No content flashes more than 3 times per second
- [ ] Or flash is below general flash threshold

## 2.4 Navigable

### 2.4.1 Bypass Blocks (Level A)

- [ ] Skip link to main content
- [ ] Landmark regions defined
- [ ] Heading structure allows navigation

```html
<!-- Skip link -->
<a href="#main-content" class="skip-link">
  Skip to main content
</a>

<header role="banner">...</header>
<nav role="navigation" aria-label="Main">...</nav>
<main id="main-content" role="main">...</main>
<footer role="contentinfo">...</footer>
```

```css
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  padding: 8px;
  background: #000;
  color: #fff;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
```

### 2.4.2 Page Titled (Level A)

```html
<!-- Unique, descriptive title -->
<title>Shopping Cart - Store Name</title>

<!-- For SPAs, update title on navigation -->
document.title = `${pageTitle} - App Name`;
```

### 2.4.3 Focus Order (Level A)

- [ ] Focus order matches visual/logical order
- [ ] Focus doesn't jump unexpectedly

### 2.4.4 Link Purpose (In Context) (Level A)

```html
<!-- BAD: Ambiguous link -->
<a href="/products/123">Click here</a>

<!-- GOOD: Descriptive link -->
<a href="/products/123">View Red Sneakers product details</a>

<!-- ACCEPTABLE: Link with context -->
<h2>Red Sneakers</h2>
<p>Classic running shoes. <a href="/products/123">View details</a></p>

<!-- GOOD: Hidden text for screen readers -->
<a href="/products/123">
  View details
  <span class="sr-only">about Red Sneakers</span>
</a>
```

### 2.4.5 Multiple Ways (Level AA)

- [ ] Multiple ways to locate pages (navigation, search, site map)

### 2.4.6 Headings and Labels (Level AA)

- [ ] Headings describe topic or purpose
- [ ] Labels describe purpose of input

### 2.4.7 Focus Visible (Level AA)

```css
/* Never remove focus outline without replacement */
/* BAD */
*:focus { outline: none; }

/* GOOD: Custom focus styles */
*:focus {
  outline: 2px solid #005fcc;
  outline-offset: 2px;
}

/* Use :focus-visible for keyboard-only focus */
*:focus:not(:focus-visible) {
  outline: none;
}

*:focus-visible {
  outline: 2px solid #005fcc;
  outline-offset: 2px;
}
```

## 2.5 Input Modalities

### 2.5.1 Pointer Gestures (Level A)

- [ ] Multi-point or path-based gestures have single-pointer alternative
- [ ] Pinch, swipe, drag have button alternatives

### 2.5.2 Pointer Cancellation (Level A)

- [ ] Down-event doesn't trigger action (use click/up)
- [ ] Ability to abort or undo actions

### 2.5.3 Label in Name (Level A)

- [ ] Accessible name contains visible label text

```html
<!-- BAD: Accessible name doesn't match visible text -->
<button aria-label="Submit form">Send</button>

<!-- GOOD: Accessible name matches visible text -->
<button>Send</button>
<!-- or -->
<button aria-label="Send message">Send</button>
```

### 2.5.4 Motion Actuation (Level A)

- [ ] Device motion actions have UI alternatives
- [ ] Motion can be disabled

```javascript
// Provide alternative to shake-to-undo
if (window.DeviceMotionEvent) {
  // Motion-based feature
} else {
  // UI-based alternative always available
}
```
```

#### Principle 3: Understandable

```markdown
## 3.1 Readable

### 3.1.1 Language of Page (Level A)

```html
<html lang="en">
```

### 3.1.2 Language of Parts (Level AA)

```html
<p>The French word for hello is <span lang="fr">bonjour</span>.</p>
```

## 3.2 Predictable

### 3.2.1 On Focus (Level A)

- [ ] Focus doesn't trigger unexpected context change
- [ ] No automatic form submission on focus

### 3.2.2 On Input (Level A)

- [ ] Input doesn't trigger unexpected context change
- [ ] Select changes don't auto-submit

```html
<!-- BAD: Auto-submit on change -->
<select onchange="this.form.submit()">

<!-- GOOD: Explicit submit button -->
<select name="filter">...</select>
<button type="submit">Apply Filter</button>
```

### 3.2.3 Consistent Navigation (Level AA)

- [ ] Navigation appears in same location
- [ ] Navigation order is consistent

### 3.2.4 Consistent Identification (Level AA)

- [ ] Same functions have same labels
- [ ] Icons used consistently

## 3.3 Input Assistance

### 3.3.1 Error Identification (Level A)

```html
<!-- Error clearly identified -->
<label for="email">Email address</label>
<input
  type="email"
  id="email"
  aria-invalid="true"
  aria-describedby="email-error"
>
<p id="email-error" role="alert" class="error">
  Please enter a valid email address
</p>
```

### 3.3.2 Labels or Instructions (Level A)

```html
<!-- Clear labels and instructions -->
<label for="dob">Date of Birth</label>
<input
  type="text"
  id="dob"
  aria-describedby="dob-hint"
  placeholder="MM/DD/YYYY"
>
<p id="dob-hint" class="hint">Enter date as MM/DD/YYYY</p>
```

### 3.3.3 Error Suggestion (Level AA)

```html
<!-- Suggest correction -->
<p id="password-error" role="alert">
  Password must be at least 8 characters and include a number.
</p>
```

### 3.3.4 Error Prevention (Legal, Financial, Data) (Level AA)

For legal/financial/data submissions:
- [ ] Submissions are reversible
- [ ] Data is checked and user can correct
- [ ] User can review before final submission

```html
<!-- Confirmation step -->
<h2>Review Your Order</h2>
<p>Please review your order details before confirming.</p>
<!-- Order summary -->
<button onclick="goBack()">Edit Order</button>
<button onclick="confirmOrder()">Confirm Order</button>
```
```

#### Principle 4: Robust

```markdown
## 4.1 Compatible

### 4.1.1 Parsing (Level A) - Obsolete in WCAG 2.2

### 4.1.2 Name, Role, Value (Level A)

**Audit Checklist:**
- [ ] Custom widgets have accessible names
- [ ] Custom widgets have appropriate roles
- [ ] State changes are communicated
- [ ] ARIA used correctly

```html
<!-- Custom toggle button -->
<button
  role="switch"
  aria-checked="false"
  onclick="toggle(this)"
>
  Dark Mode
</button>

<script>
function toggle(btn) {
  const checked = btn.getAttribute('aria-checked') === 'true';
  btn.setAttribute('aria-checked', !checked);
}
</script>

<!-- Custom tabs -->
<div role="tablist" aria-label="Settings">
  <button role="tab" aria-selected="true" aria-controls="panel-1">
    General
  </button>
  <button role="tab" aria-selected="false" aria-controls="panel-2">
    Privacy
  </button>
</div>
<div role="tabpanel" id="panel-1">...</div>
<div role="tabpanel" id="panel-2" hidden>...</div>
```

### 4.1.3 Status Messages (Level AA)

```html
<!-- Announce status changes -->
<div role="status" aria-live="polite">
  3 search results found
</div>

<!-- Announce errors -->
<div role="alert" aria-live="assertive">
  Form submission failed. Please try again.
</div>

<!-- Loading states -->
<button aria-busy="true" disabled>
  <span class="sr-only">Loading...</span>
  Saving...
</button>
```
```

### Phase 3: Assistive Technology Testing

```markdown
## Screen Reader Testing

### NVDA (Windows - Free)

**Essential Commands:**
| Action | Shortcut |
|--------|----------|
| Toggle browse mode | Insert + Space |
| Next heading | H |
| Previous heading | Shift + H |
| Heading level | 1-6 |
| Next link | K |
| Next button | B |
| Next form field | F |
| Next table | T |
| List elements | Insert + F7 |
| Next landmark | D |
| Read all | Insert + Down Arrow |

**Testing Checklist:**
- [ ] All content is announced
- [ ] Images have appropriate alt text
- [ ] Headings structure is logical
- [ ] Form labels are announced
- [ ] Error messages are announced
- [ ] Dynamic content updates are announced
- [ ] Focus management works correctly

### VoiceOver (macOS/iOS)

**macOS Commands:**
| Action | Shortcut |
|--------|----------|
| Toggle VoiceOver | Cmd + F5 |
| VoiceOver key (VO) | Ctrl + Option |
| Navigate | VO + Arrow keys |
| Interact | VO + Shift + Down |
| Stop interacting | VO + Shift + Up |
| Rotor | VO + U |
| Read all | VO + A |

**iOS Testing:**
1. Settings > Accessibility > VoiceOver
2. Swipe right to navigate
3. Double-tap to activate
4. Two-finger swipe down to read all
5. Rotor: Two-finger rotate

### JAWS (Windows - Commercial)

**Key Commands:**
| Action | Shortcut |
|--------|----------|
| Next heading | H |
| Links list | Insert + F7 |
| Forms list | Insert + F5 |
| Say all | Insert + Down |

## Keyboard-Only Testing

**Standard Keys:**
| Action | Key |
|--------|-----|
| Navigate forward | Tab |
| Navigate backward | Shift + Tab |
| Activate | Enter |
| Toggle/Select | Space |
| Navigate within widget | Arrow keys |
| Close/Cancel | Escape |
| Submit | Enter (in forms) |

**Testing Checklist:**
- [ ] Can reach all interactive elements
- [ ] Focus is always visible
- [ ] Focus order is logical
- [ ] Can escape from all areas
- [ ] All actions possible via keyboard
- [ ] No keyboard traps

## Browser Accessibility Tools

### Chrome DevTools
1. Elements panel > Accessibility pane
2. Lighthouse audit
3. CSS Overview for contrast issues

### Firefox DevTools
1. Accessibility panel
2. Check for issues automatically
3. Simulate vision deficiencies

### axe DevTools Extension
- Automatic WCAG testing
- Detailed remediation guidance
- Issue severity ratings
```

### Phase 4: Automated Testing

```markdown
## Automated Testing Tools

### axe-core

```javascript
// Jest/Testing Library integration
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('component is accessible', async () => {
  const { container } = render(<MyComponent />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});

// Cypress integration
describe('Accessibility', () => {
  it('has no violations', () => {
    cy.visit('/');
    cy.injectAxe();
    cy.checkA11y();
  });
});

// Playwright integration
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('page is accessible', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

### Lighthouse

```bash
# CLI
npx lighthouse https://example.com --only-categories=accessibility

# CI Integration
npx lhci autorun
```

### Pa11y

```bash
# CLI
npx pa11y https://example.com

# CI configuration
# .pa11yci
{
  "defaults": {
    "standard": "WCAG2AA",
    "runners": ["axe", "htmlcs"]
  },
  "urls": [
    "http://localhost:3000/",
    "http://localhost:3000/about"
  ]
}
```

### ESLint Plugin

```javascript
// .eslintrc.js
module.exports = {
  plugins: ['jsx-a11y'],
  extends: ['plugin:jsx-a11y/recommended'],
  rules: {
    'jsx-a11y/alt-text': 'error',
    'jsx-a11y/anchor-has-content': 'error',
    'jsx-a11y/label-has-associated-control': 'error',
  },
};
```
```

### Phase 5: Audit Report Generation

```markdown
# Accessibility Audit Report

## Executive Summary
- **Audit Date:** [Date]
- **URL/Application:** [Target]
- **Compliance Target:** WCAG 2.1 AA
- **Overall Score:** [Pass/Partial/Fail]
- **Issues Found:** [X Critical, Y Serious, Z Minor]

## Compliance Summary

| Principle | Status | Issues |
|-----------|--------|--------|
| 1. Perceivable | [Status] | [Count] |
| 2. Operable | [Status] | [Count] |
| 3. Understandable | [Status] | [Count] |
| 4. Robust | [Status] | [Count] |

## Critical Issues (Must Fix)

### Issue 1: [Title]
- **WCAG Criterion:** [e.g., 1.1.1 Non-text Content]
- **Severity:** Critical
- **Location:** [Page/Component]
- **Description:** [What's wrong]
- **Impact:** [Who is affected and how]
- **Remediation:** [How to fix]
- **Code Example:**
```html
<!-- Current (problematic) -->
<img src="product.jpg">

<!-- Recommended (accessible) -->
<img src="product.jpg" alt="Red leather handbag">
```

## Serious Issues (Should Fix)
[Same format]

## Minor Issues (Nice to Fix)
[Same format]

## Testing Methodology
- Automated testing with axe-core
- Manual keyboard navigation testing
- Screen reader testing (NVDA, VoiceOver)
- Color contrast analysis
- Responsive testing

## Recommendations
1. [Priority recommendation]
2. [Secondary recommendation]
3. [Ongoing improvements]

## Resources
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
```

## Accessible Component Patterns

```html
<!-- Accessible Modal -->
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
  aria-describedby="modal-desc"
>
  <h2 id="modal-title">Confirm Action</h2>
  <p id="modal-desc">Are you sure you want to proceed?</p>
  <button onclick="closeModal()">Cancel</button>
  <button onclick="confirm()">Confirm</button>
</div>

<!-- Accessible Accordion -->
<div class="accordion">
  <h3>
    <button
      aria-expanded="false"
      aria-controls="panel-1"
      onclick="togglePanel(this)"
    >
      Section 1
    </button>
  </h3>
  <div id="panel-1" hidden>
    Panel content...
  </div>
</div>

<!-- Accessible Tabs -->
<div role="tablist" aria-label="Settings tabs">
  <button
    role="tab"
    aria-selected="true"
    aria-controls="panel-general"
    id="tab-general"
  >
    General
  </button>
  <button
    role="tab"
    aria-selected="false"
    aria-controls="panel-privacy"
    id="tab-privacy"
    tabindex="-1"
  >
    Privacy
  </button>
</div>
<div
  role="tabpanel"
  id="panel-general"
  aria-labelledby="tab-general"
>
  General settings content...
</div>
<div
  role="tabpanel"
  id="panel-privacy"
  aria-labelledby="tab-privacy"
  hidden
>
  Privacy settings content...
</div>
```

## Best Practices

1. **Start with Semantic HTML** - ARIA is a last resort
2. **Test Early and Often** - Catch issues before production
3. **Use Automated Tools** - But don't rely on them alone
4. **Test with Real Users** - Include users with disabilities
5. **Keyboard First** - If it works with keyboard, it usually works with screen readers
6. **Visible Focus** - Never hide focus indicators
7. **Color is Not Enough** - Use multiple indicators
8. **Write Meaningful Text** - Alt text, link text, labels
9. **Manage Focus** - Especially in SPAs and modals
10. **Document Decisions** - Record accessibility choices

## Notes

- Accessibility is an ongoing commitment, not a one-time fix
- Legal requirements vary by jurisdiction
- User testing with assistive technology users is invaluable
- Automated tools catch ~30% of issues; manual testing is essential
- Good accessibility benefits all users, not just those with disabilities
