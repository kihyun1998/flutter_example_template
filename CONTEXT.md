# Gallery

The chrome a Flutter package is demonstrated in, carrying no knowledge of which package that is.
A consumer supplies the subject through three ports; everything here is drawn without naming it.

## Language

### The gallery and its seam

**Gallery**:
This package — the reusable chrome a package is demonstrated in.
_Avoid_: Example app, demo app, showcase

**Subject**:
The package a gallery is demonstrating. The gallery never names it.
_Avoid_: Demonstrated package, target, subject package, SUT

**Chrome**:
The gallery's own interface around the subject — the app bar, the menu, the panes the reader
operates. It carries no hue, so the only colour on screen is the subject's.
_Avoid_: Furniture, shell (a Shell is one page), decoration

**Consumer**:
The application that adopts the gallery and supplies the subject through the ports.
_Avoid_: Client, host app, integrator

**Reader**:
The person the gallery is drawn for, evaluating the subject before adopting it. Not the consumer,
who has already adopted it.
_Avoid_: User, viewer, visitor

**Port**:
An abstract class the consumer implements to supply what the gallery must not name.
_Avoid_: Interface, contract, adapter

**Seam**:
Where the gallery meets the subject — the ports, and the rules that keep the two apart.
_Avoid_: Boundary, interface, layer

**Zone**:
A region of files governed by one import rule.
_Avoid_: Boundary, module, package

**Barrel**:
The gallery's single public entry point. A symbol is exported there or it is not public.
_Avoid_: Index, entry file, facade

**Area**:
One directory under the gallery's internals, holding one cluster of the implementation.
_Avoid_: Module, folder, layer

### The shell

**Shell**:
The gallery's page: a menu, a preview stage and a knob region, holding one destination at a time.
_Avoid_: Layout, scaffold, frame

**Destination**:
One entry the menu points at.
_Avoid_: Page, route, item, tab

**Stage destination**:
A destination the shell draws itself, in its stage and its knob region.

**Route destination**:
A destination that opens on its own route. The shell hands over rather than absorbing it.

**Category**:
One of the three groups the menu shows. Two name content and the third names a hosting kind.
_Avoid_: Section, group (a Group is a settings-panel term)

**Recipe**:
One pasteable, self-contained feature file.
_Avoid_: Sample, snippet, example

**Scenario**:
Several features assembled into one situation.
_Avoid_: Demo, use case, story

**Knob region**:
The shell region a destination fills with its own controls.
_Avoid_: Sidebar, panel, inspector

**Knobs**:
What one destination puts in the knob region — a subtree, not a roster the shell can enumerate.
_Avoid_: Controls, settings, props

**Code pane**:
A recipe's own source, read out of the bundle so that what runs and what is shown cannot disagree.
Not a general source viewer: it is the affordance of the pasteable claim.
_Avoid_: Source pane, source viewer, file pane

### The preview

**Viewport**:
One named size the preview pretends to be, and whether a shell keeps its furniture at that width.
_Avoid_: Device, breakpoint, screen size

**Preview stage**:
The layer that constrains a subtree to a viewport and tells it that is the whole screen. It never
scales.
_Avoid_: Frame, canvas

**Preview frame**:
A preview stage scaled to fit the room it is given, captioned with its dimensions and its factor.
_Avoid_: Stage, window, card

**Device Wall**:
The mode that draws every viewport at once, live, over one set of knobs. It answers what changed
between the widths, which no single-viewport mode can.
_Avoid_: Grid, multi-preview, side-by-side

**Fit**:
Shrinking a whole viewport into view, as opposed to showing a 1:1 slice of it.
_Avoid_: Scale, zoom, shrink

### The settings panel

**Spec**:
The description a settings panel is drawn from — groups, features, options and interactions. It
holds no settings itself.
_Avoid_: Schema, config, model

**Group**:
Features cut by what a reader is trying to do, never by what they configure.
_Avoid_: Category (a Category is a menu term), section

**Feature**:
A capability of the subject, and the settings that only mean something once it is on.
_Avoid_: Module, capability, section

**Switch**:
The boolean that turns a feature on. A feature without one is always live.
_Avoid_: Toggle, flag, enabled

**Control**:
One labelled, id'd widget in the settings panel. The label travels with it, so a search can read it
before it is built.
_Avoid_: Knob, widget, input, field

**Option**:
A setting that is only meaningful while its feature is on.
_Avoid_: Property, field, parameter

**Interaction**:
One feature changing another, stated in the direction it happens.
_Avoid_: Dependency, coupling, relationship

**Evidence**:
The citation that establishes an interaction. No interaction is asserted without one.
_Avoid_: Reference, proof, justification

**Preset**:
A named combination of features, earning its name from the interaction it produces rather than the
switches it flips.
_Avoid_: Profile, preset config, scenario (a Scenario is a destination)

**Look-for**:
What to watch once a preset is applied.
_Avoid_: Description, hint, caption
