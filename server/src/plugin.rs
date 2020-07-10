use std::error::Error;
use wasmtime::{Module, Instance, Trap};

pub struct Plugin {
    realloc_func: Box<dyn Fn(i32, i32, i32) -> Result<i32, Trap>>,
}

impl Plugin {
    pub fn realloc(&self, old_ptr: usize, old_len: usize, new_len: usize) -> Result<usize, Trap> {
        (self.realloc_func)(old_ptr as u32 as i32, old_len as u32 as i32, new_len as u32 as i32).map(|x| x as u32 as usize)
    }
}

pub fn extract_plugin(module: &Module, instance: &Instance) -> Result<Plugin, Box<dyn Error>> {
    let realloc = instance.get_func("realloc")
        .ok_or(anyhow::format_err!("failed to find `on_enable` function export"))?
        .get3::<i32, i32, i32, i32>()?;

    return Ok(Plugin {
        realloc_func: Box::new(realloc)
    });
}
