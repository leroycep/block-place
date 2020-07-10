use std::error::Error;
use wasmtime::{Module, Instance, Trap};

pub struct Plugin {
    realloc_func: Box<dyn Fn(i32, i32) -> Result<i32, Trap>>,
}

impl Plugin {
    pub fn realloc(&self, old_ptr: Option<usize>, new_len: usize) -> Result<Option<usize>, Trap> {
        (self.realloc_func)(old_ptr.unwrap_or(0) as u32 as i32, new_len as u32 as i32)
            .map(|x| if x == 0 {
                None
            } else {
                Some(x as u32 as usize)
            })
    }
}

pub fn extract_plugin(module: &Module, instance: &Instance) -> Result<Plugin, Box<dyn Error>> {
    let realloc = instance.get_func("realloc")
        .ok_or(anyhow::format_err!("failed to find `on_enable` function export"))?
        .get2::<i32, i32, i32>()?;

    return Ok(Plugin {
        realloc_func: Box::new(realloc)
    });
}
