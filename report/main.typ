#import "@preview/codly:1.2.0" as codly:
#import "util.typ" as util: code_figure, src_link


#set document(
	author: "Filipe Rodrigues",
	title: util.title,
	date: none
)
#set page(
	header: context {
		if counter(page).get().first() > 1 {
			image("images/tecnico-logo.png", height: 30pt)
		}
	},
	footer: context {
		if counter(page).get().first() > 1 {
			align(center, counter(page).display())
		}
	},
	margin: (x: 2cm, y: 30pt + 1.5cm)
)
#set text(
	font: "Libertinus Serif",
	lang: "en",
)
#set par(
	justify: true,
	leading: 0.65em,
)
#show link: underline

#show: codly.codly-init.with()

#include "cover.typ"
#pagebreak()

= Setup

The setup for this project is simple, as no connections to any external pins are required.

We simply connected the esp32 via usb and flashed the program to it, observing it's output through the terminal's output.

= Experiment

== Step 1: Understand Default Logging Levels

When running the program initially, we'd expect `LOG1` to output for the default level and above. Reading the logging documentation @logging-docs, we can see that this level depends on the `CONFIG_LOG_DEFAULT_LEVEL` variable, with the following values:

- `ESP_LOG_NONE    (0)`: No output
- `ESP_LOG_ERROR   (1)`: Error
- `ESP_LOG_WARN    (2)`: Warning
- `ESP_LOG_INFO    (3)`: Info
- `ESP_LOG_DEBUG   (4)`: Debug
- `ESP_LOG_VERBOSE (5)`: Verbose

After setting up our project, we can look through the auto-generated `sdkconfig` to find that `CONFIG_LOG_DEFAULT_LEVEL` is set to `3` (`ESP_LOG_INFO`), meaning that `INFO` is the default level.

As for `LOG2`, we would expect that `DEBUG` and above would be logged due to us setting the level.

Running the project with the `step1` function yields the following output:

#codly.codly(
	highlights: (
		(line: 1, fill: red),
		(line: 2, fill: yellow),
		(line: 3, fill: green),

		(line: 4, fill: red),
		(line: 5, fill: yellow),
		(line: 6, fill: green),
	),
)
```
E (273) LOG1: LOG FOR ERRORS 0
W (283) LOG1: LOG FOR WARNINGS 1
I (283) LOG1: LOG FOR INFORMATION 2
E (293) LOG2: LOG FOR ERRORS
W (293) LOG2: LOG FOR WARNINGS
I (293) LOG2: LOG FOR INFORMATION
```

We can see that our expectation for `LOG1` is correct, but we're missing the expected `DEBUG` output for `LOG2`.

This can be explained by reading the documentation, and seeing that `CONFIG_LOG_DEFAULT_LEVEL` is the max level set at *compile-time*. This means that all logs compiled below this level won't actually end up in the final program binary.

We can change the `CONFIG_LOG_DEFAULT_LEVEL` level through `idf.py menuconfig` (in `(Top) → Component config → Log output → Default log verbosity`) to, for example, `Verbose`. Doing this and running the program again with `step1`, we get the following:

#codly.codly(
	highlights: (
		(line: 1, fill: red),
		(line: 2, fill: yellow),
		(line: 3, fill: green),

		(line: 6, fill: red),
		(line: 7, fill: yellow),
		(line: 8, fill: green),
	),
)
```
E (735) LOG1: LOG FOR ERRORS 0
W (735) LOG1: LOG FOR WARNINGS 1
I (745) LOG1: LOG FOR INFORMATION 2
D (745) LOG1: LOG FOR DEBUG 3
V (745) LOG1: LOG FOR VERBOSE 4
E (755) LOG2: LOG FOR ERRORS
W (755) LOG2: LOG FOR WARNINGS
I (755) LOG2: LOG FOR INFORMATION
D (765) LOG2: LOG FOR DEBUG
```

We can see that the default level is now `VERBOSE`. We also see that `LOG2` doesn't log it's verbose level since we set the level to `DEBUG`.

For the next steps, we'll change the compile-time default logging back to `Info`.

== Step 2: Modify Global Logging Level

We'll not modify the global logging level and see how that affects our program. To see changes, we'll set the global level to `ESP_LOG_ERROR`, `ESP_LOG_WARN` and `ESP_LOG_INFO`.

Running the project with the `step2` function yields the following outputs for the respective error levels mentioned above:

#grid(columns: 3,
	[
		#codly.codly(
			highlights: (
				(line: 1, fill: red),

				(line: 2, fill: red),
				(line: 3, fill: yellow),
				(line: 4, fill: green),
			),
		)
		```
		E (273) LOG1: LOG FOR ERRORS 0
		E (283) LOG2: LOG FOR ERRORS
		W (283) LOG2: LOG FOR WARNINGS
		I (283) LOG2: LOG FOR INFORMATION
		```
	],
	[
		#codly.codly(
			highlights: (
				(line: 1, fill: red),
				(line: 2, fill: yellow),

				(line: 3, fill: red),
				(line: 4, fill: yellow),
				(line: 5, fill: green),
			),
		)
		```
		E (273) LOG1: LOG FOR ERRORS 0
		W (283) LOG1: LOG FOR WARNINGS 1
		E (283) LOG2: LOG FOR ERRORS
		W (283) LOG2: LOG FOR WARNINGS
		I (283) LOG2: LOG FOR INFORMATION
		```
	],
	[
		#codly.codly(
			highlights: (
				(line: 1, fill: red),
				(line: 2, fill: yellow),
				(line: 3, fill: green),

				(line: 4, fill: red),
				(line: 5, fill: yellow),
				(line: 6, fill: green),
			),
		)
		```
		E (273) LOG1: LOG FOR ERRORS 0
		W (283) LOG1: LOG FOR WARNINGS 1
		I (283) LOG1: LOG FOR INFORMATION 2
		E (283) LOG2: LOG FOR ERRORS
		W (283) LOG2: LOG FOR WARNINGS
		I (283) LOG2: LOG FOR INFORMATION
		```
	],
)

We can see that setting the global level, `"*"`, sets the *runtime* default level for all logs that don't have a log set, which is `LOG1` in our case. As for logs that set their level, they will ignore this default and use their own level.

== Step 3: Configure Logging for Specific Tags

Setting a specific log for `LOG1` acts just as above, where the default log affected it.

A per-tag logging level is useful because many times when solving a problem or working on a new feature, we don't need to know the details of every single other feature.

For example, when debugging an issue with bluetooth, we want detailed logs for bluetooth related issues, but we don't care about detailed logs for things like GPIO, USB or battery.

= Discussion Questions

== Why are logging levels important in embedded systems development?

In general, logging levels are important in software development, since they allow us to quickly tell at a glance the importance of a line of output, and what it relates to.

== How does filtering logs by tag or level contribute to system debugging and efficiency?

By filtering logs using a tag and level, we can focus on the issue at hand instead of having to sift through all logs to find anything related to our specific problem.

== What are the potential risks of excessive logging in resource-constrained systems?

Performance is a typical issue we run into when logging. However, having compile-time logging levels set means that even if we declare plenty of logs, only a certain few will make it to the final binary.

== How could you use logs to monitor system health in a production environment?

We could create a task that wakes up every once in a while, and checks the health of all of the components, logging it's output.

This way, we could inspect the logs regularly and ensure that all systems are still functional.

We could also setup some system to ensure that a warning or error from this system is immediately relayed to us, so we can act on system/component failure quickly.

==

#bibliography("bibliography.yaml", style: "ieee", full: true)
