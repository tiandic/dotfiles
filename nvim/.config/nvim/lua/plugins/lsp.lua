return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
                diagnosticSeverityOverrides = {
                  reportMissingParameterType = "none",
                  reportMissingTypeArgument = "none",
                  reportUnknownVariableType = "none",
                  reportUnknownMemberType = "none",
                  reportUnknownArgumentType = "none",
                  reportUnknownParameterType = "none",
                  reportUnknownLambdaType = "none",
                },
              },
            },
          },
        },
        clangd = {
          cmd = {
            "clangd",
            "--function-arg-placeholders=false",
          },
        },
      },
    },
  },
}
