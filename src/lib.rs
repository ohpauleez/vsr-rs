#![deny(clippy::pedantic, clippy::clone_on_ref_ptr, missing_docs)]

pub mod client;
pub mod config;
pub mod message;
//pub mod replica;
pub mod replicapdg;

mod types;

#[cfg(test)]
mod tests;

pub use client::Client;
pub use config::Config;
pub use message::Message;
//pub use replica::{Replica, StateMachine};
pub use replicapdg::{Replica, StateMachine};
