use proc_macro::TokenStream;
use quote::quote;

#[proc_macro_derive(IsCap)]
pub fn derive_cap(input: TokenStream) -> TokenStream {
    let ast = syn::parse(input).unwrap();
    derive_cap_impl(&ast)
}

fn derive_cap_impl(ast: &syn::DeriveInput) -> TokenStream {
    let name = &ast.ident;
    let gen = quote! {
        impl<'b> TryFrom<&'b Cap> for &'b #name {
            type Error = TryFromCapError;
            fn try_from(cap: &'b Cap) -> Result<Self, Self::Error> {
                match cap {
                    Cap::#name(cap) => Ok(&cap),
                    _ => Err(TryFromCapError),
                }
            }
        }
        impl Into<Cap> for #name {
            fn into(self) -> Cap {
                Cap::#name(self)
            }
        }
    };
    gen.into()
}

#[proc_macro_derive(IsObject)]
pub fn derive_object(input: TokenStream) -> TokenStream {
    let ast = syn::parse(input).unwrap();
    derive_object_impl(&ast)
}

fn derive_object_impl(ast: &syn::DeriveInput) -> TokenStream {
    let name = &ast.ident;
    let generics = &ast.generics;
    let gen = quote! {
        impl<'a, 'b, F> TryFrom<&'b Object<'a, F>> for &'b #name #generics {
            type Error = TryFromObjectError;
            fn try_from(obj: &'b Object<'a, F>) -> Result<Self, Self::Error> {
                match obj {
                    Object::#name(cap) => Ok(&cap),
                    _ => Err(TryFromObjectError),
                }
            }
        }
        impl<'a, F> Into<Object<'a, F>> for #name #generics {
            fn into(self) -> Object<'a, F> {
                Object::#name(self)
            }
        }
    };
    gen.into()
}