---
name: form-design
description: Build accessible, user-friendly forms with validation. Covers react-hook-form, Zod schemas, error handling UX, multi-step forms, input patterns, and form accessibility. Use for registration forms, checkout flows, data entry, and user input.
---

# Form Design & Development

Build accessible, user-friendly forms with proper validation and error handling.

## Instructions

1. **Use react-hook-form** - Performant form state management
2. **Validate with Zod** - Type-safe schema validation
3. **Show errors inline** - Near the relevant field
4. **Provide clear feedback** - Success, error, and loading states
5. **Ensure accessibility** - Labels, ARIA attributes, keyboard navigation

## React Hook Form + Zod

### Basic Form Setup

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const formSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain an uppercase letter')
    .regex(/[0-9]/, 'Password must contain a number'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
});

type FormData = z.infer<typeof formSchema>;

export function SignupForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(formSchema),
  });

  const onSubmit = async (data: FormData) => {
    try {
      await createAccount(data);
    } catch (error) {
      // Handle API errors
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          {...register('email')}
          aria-invalid={!!errors.email}
          aria-describedby={errors.email ? 'email-error' : undefined}
        />
        {errors.email && (
          <p id="email-error" role="alert">{errors.email.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          {...register('password')}
          aria-invalid={!!errors.password}
          aria-describedby={errors.password ? 'password-error' : undefined}
        />
        {errors.password && (
          <p id="password-error" role="alert">{errors.password.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="confirmPassword">Confirm Password</label>
        <input
          id="confirmPassword"
          type="password"
          {...register('confirmPassword')}
          aria-invalid={!!errors.confirmPassword}
        />
        {errors.confirmPassword && (
          <p role="alert">{errors.confirmPassword.message}</p>
        )}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating account...' : 'Sign Up'}
      </button>
    </form>
  );
}
```

### Reusable Form Field Component

```tsx
import { useFormContext } from 'react-hook-form';

interface FormFieldProps {
  name: string;
  label: string;
  type?: string;
  placeholder?: string;
  hint?: string;
}

export function FormField({
  name,
  label,
  type = 'text',
  placeholder,
  hint,
}: FormFieldProps) {
  const {
    register,
    formState: { errors },
  } = useFormContext();

  const error = errors[name]?.message as string | undefined;
  const inputId = `field-${name}`;
  const errorId = `${inputId}-error`;
  const hintId = `${inputId}-hint`;

  return (
    <div className="space-y-1">
      <label
        htmlFor={inputId}
        className="block text-sm font-medium text-gray-700"
      >
        {label}
      </label>

      <input
        id={inputId}
        type={type}
        placeholder={placeholder}
        {...register(name)}
        className={`
          w-full px-3 py-2 border rounded-lg
          ${error ? 'border-red-500' : 'border-gray-300'}
          focus:outline-none focus:ring-2
          ${error ? 'focus:ring-red-500' : 'focus:ring-blue-500'}
        `}
        aria-invalid={!!error}
        aria-describedby={
          error ? errorId : hint ? hintId : undefined
        }
      />

      {hint && !error && (
        <p id={hintId} className="text-sm text-gray-500">
          {hint}
        </p>
      )}

      {error && (
        <p id={errorId} className="text-sm text-red-600" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}
```

## Multi-Step Forms

```tsx
import { useState } from 'react';
import { useForm, FormProvider } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Step schemas
const step1Schema = z.object({
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().min(1, 'Last name is required'),
  email: z.string().email('Invalid email'),
});

const step2Schema = z.object({
  address: z.string().min(1, 'Address is required'),
  city: z.string().min(1, 'City is required'),
  zipCode: z.string().regex(/^\d{5}$/, 'Invalid ZIP code'),
});

const step3Schema = z.object({
  cardNumber: z.string().regex(/^\d{16}$/, 'Invalid card number'),
  expiry: z.string().regex(/^\d{2}\/\d{2}$/, 'Format: MM/YY'),
  cvv: z.string().regex(/^\d{3,4}$/, 'Invalid CVV'),
});

const fullSchema = step1Schema.merge(step2Schema).merge(step3Schema);
type FormData = z.infer<typeof fullSchema>;

const steps = [
  { schema: step1Schema, title: 'Personal Info' },
  { schema: step2Schema, title: 'Address' },
  { schema: step3Schema, title: 'Payment' },
];

export function MultiStepForm() {
  const [currentStep, setCurrentStep] = useState(0);

  const methods = useForm<FormData>({
    resolver: zodResolver(fullSchema),
    mode: 'onChange',
  });

  const { trigger, handleSubmit } = methods;

  const goToNextStep = async () => {
    const currentSchema = steps[currentStep].schema;
    const fields = Object.keys(currentSchema.shape) as (keyof FormData)[];

    const isValid = await trigger(fields);
    if (isValid) {
      setCurrentStep((prev) => prev + 1);
    }
  };

  const goToPreviousStep = () => {
    setCurrentStep((prev) => prev - 1);
  };

  const onSubmit = async (data: FormData) => {
    console.log('Form submitted:', data);
  };

  return (
    <FormProvider {...methods}>
      <form onSubmit={handleSubmit(onSubmit)}>
        {/* Progress indicator */}
        <div className="flex justify-between mb-8">
          {steps.map((step, index) => (
            <div
              key={step.title}
              className={`flex items-center ${
                index <= currentStep ? 'text-blue-600' : 'text-gray-400'
              }`}
            >
              <span className={`
                w-8 h-8 rounded-full flex items-center justify-center
                ${index <= currentStep ? 'bg-blue-600 text-white' : 'bg-gray-200'}
              `}>
                {index + 1}
              </span>
              <span className="ml-2 text-sm">{step.title}</span>
            </div>
          ))}
        </div>

        {/* Step content */}
        {currentStep === 0 && <Step1 />}
        {currentStep === 1 && <Step2 />}
        {currentStep === 2 && <Step3 />}

        {/* Navigation */}
        <div className="flex justify-between mt-8">
          <button
            type="button"
            onClick={goToPreviousStep}
            disabled={currentStep === 0}
            className="px-4 py-2 border rounded disabled:opacity-50"
          >
            Previous
          </button>

          {currentStep < steps.length - 1 ? (
            <button
              type="button"
              onClick={goToNextStep}
              className="px-4 py-2 bg-blue-600 text-white rounded"
            >
              Next
            </button>
          ) : (
            <button
              type="submit"
              className="px-4 py-2 bg-green-600 text-white rounded"
            >
              Submit
            </button>
          )}
        </div>
      </form>
    </FormProvider>
  );
}
```

## Accessible Form Patterns

### Required Field Indicators

```tsx
<label htmlFor="email">
  Email
  <span className="text-red-500" aria-hidden="true">*</span>
  <span className="sr-only">(required)</span>
</label>
```

### Error Announcements

```tsx
// Live region for form errors
<div
  role="alert"
  aria-live="polite"
  className="sr-only"
>
  {Object.keys(errors).length > 0 && (
    `Form has ${Object.keys(errors).length} errors. Please correct them.`
  )}
</div>
```

### Focus Management

```tsx
const { setFocus } = useForm();

// Focus first error field on submit failure
const onInvalid = () => {
  const firstErrorField = Object.keys(errors)[0];
  if (firstErrorField) {
    setFocus(firstErrorField as keyof FormData);
  }
};

<form onSubmit={handleSubmit(onSubmit, onInvalid)}>
```

## Input Patterns

### Phone Number Input

```tsx
const phoneSchema = z.string().regex(
  /^\+?[1-9]\d{1,14}$/,
  'Enter a valid phone number'
);

<input
  type="tel"
  inputMode="tel"
  autoComplete="tel"
  placeholder="+1 (555) 123-4567"
/>
```

### Date Input

```tsx
const dateSchema = z.string().refine(
  (date) => !isNaN(Date.parse(date)),
  'Enter a valid date'
);

<input
  type="date"
  min={new Date().toISOString().split('T')[0]}
  autoComplete="bday"
/>
```

### Currency Input

```tsx
const currencySchema = z
  .string()
  .transform((val) => parseFloat(val.replace(/[^0-9.]/g, '')))
  .refine((val) => !isNaN(val) && val >= 0, 'Enter a valid amount');

<input
  type="text"
  inputMode="decimal"
  placeholder="$0.00"
  onChange={(e) => {
    const value = e.target.value.replace(/[^0-9.]/g, '');
    const formatted = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(parseFloat(value) || 0);
    e.target.value = formatted;
  }}
/>
```

## Best Practices

1. **Validate on blur** - Show errors after user leaves field
2. **Clear errors on focus** - Give users a fresh start
3. **Use native inputs** - Better mobile experience
4. **Show password requirements** - Before user types
5. **Disable submit while invalid** - Prevent frustration
6. **Save progress** - For multi-step forms
7. **Handle server errors** - Display API validation errors

## When to Use

- User registration and login
- Checkout and payment flows
- Profile and settings pages
- Data entry applications
- Survey and feedback forms

## Notes

- Always use `noValidate` on forms to control validation
- Use `inputMode` for mobile keyboards
- Test with keyboard-only navigation
- Consider autofill attributes for better UX
