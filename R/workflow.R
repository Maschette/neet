#' Worfklow
#'
#' Draw an image of a testing workflow and where the user is up to in the
#' process.
#'
#' This was adapted from code snippets posted in this
#' [thread](https://twitter.com/CSchmert/status/1224333501840928770?s=20).

# acknowledgements
# https://twitter.com/CSchmert/status/1224333501840928770?s=20
# radians <- seq(0, 6*pi, length.out = 600)
# df <- data.frame(
#   x = cos(radians) + seq(0, 6, length.out = 600),
#   y = sin(radians)
# )
# plot(df$x, df$y, type = 'l')

#'
#' @export

workflow <- function(progress = 0) {
  n <- 600


  offset <- seq(from = 0,
                to = 1,
                length = n)


  loop <- tibble::tibble(
    theta = seq(
      from = 0,
      to = 6 * pi,
      length = n
    ),
    x = -cos(theta) + offset,
    y = sin(theta)
  ) %>%
    dplyr::mutate(progress = dplyr::row_number())

  fetchpoints <- function(cut_off) {
    loop %>%
      dplyr::filter(theta <= cut_off) %>%
      dplyr::slice(nrow(.))
  }

  points <-
    c(0, 2 * pi / 3, 4 * pi / 3) %>% c(., . + 2 * pi, . + 4 * pi, 6 * pi) %>%
    purrr::map_df(fetchpoints) %>%
    dplyr::mutate(
      label = c("code::registration",
                "tests",
                "code") %>% rep(3) %>% c(., "code::registration"),
      label = factor(label, levels = c("code::registration", "tests", "code"))
    )

  neet_labels <- c("one neet", "all neets", "and the rest")

  neets <- points %>%
    dplyr::filter(label == "tests") %>%
    dplyr::mutate(
      test = neet_labels,
      test = forcats::fct_relevel(test, neet_labels),
      label = as.factor(label),
      label = forcats::fct_relevel(label, "code::registration", "tests", "code")
    )


  point_size <- 7
  alpha_workflow <- 0.3
  alpha_progress <- 0.4

  suppressWarnings(
    workflow <-
      loop %>%
      ggplot2::ggplot(ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_path(ggplot2::aes(group = 1), alpha = alpha_workflow, colour = "grey") +
      ggplot2::theme_void() +
      ggplot2::geom_point(
        data = points,
        size = point_size,
        alpha = alpha_workflow,
        ggplot2::aes(x = x, y = y, colour = label)
      ) +
      ggplot2::geom_point(
        data = dplyr::slice(loop, 1, nrow(loop)),
        size = point_size,
        colour = "grey",
        alpha = alpha_workflow
      ) +
      hrbrthemes::scale_color_ipsum("workflow") +
      ggplot2::geom_point(
        data = neets,
        size = point_size / 2,
        alpha = alpha_workflow,
        ggplot2::aes(shape = test)
      )
    # + ggplot2::labs(x = "code::proof to doneness workflow with code::registration")
  )

  if (progress == 0) {
    workflow
  } else
  {
    cut_off <- points[progress,] %>% purrr::pluck("theta")

    suppressWarnings(
      workflow +
        ggplot2::geom_path(
          data = loop %>% dplyr::filter(theta <= cut_off),
          colour = "darkblue",
          ggplot2::aes(group = 1),
          alpha = alpha_progress
        ) +
        ggplot2::geom_point(
          data = loop %>%
            dplyr::filter(theta <= cut_off) %>%
            dplyr::slice(1, nrow(.)),
          colour = "darkblue",
          alpha = alpha_progress,
          size = point_size
        )

    )
  }
}
