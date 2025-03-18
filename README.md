# surprisal\_coding\_analyses

Each session consists of a `.mat` file consisting of a single variable called
`datastruct`, whose structure is as follows:

| Field Name     | Field Description                                         |
| -------------- | --------------------------------------------------------- |
| areas          | Areas x 1 cell array of area names for elements of `muae` |
| session        | Character array giving the name of the session NWB file   |
| muae           | 1 x A cell array of Channels x Samples x Trials MUAe data |
| times_in_trial | 1 x A cell array of 1 x Samples timestamps, starting at 0 |
| stim_info      | A Trials x 4 x 7 array of regressors (see below)          |
| stim_times     | A Trials x 5 x 2 array of timestamps (see below)          |

`muae` data have undergone the following preprocessing steps:

* Epoching (hence treating Samples as a constant) of each correct trial.
* Baselining (with the same baselining parameters as the paper's other analyses)
* SEM normalization (calculate the trial-wise standard error of the mean at each
  sample in time and elementwise-divide by them)
* Smoothing with a presynaptic spiking kernel, eg:
```
krnl = spks_kernel('psp', 10);
muae = convn(muae, krnl, 'same');
```
* Channel selection for visually responsive channels, specifically only those
responding to presentations with an increase.

The `times_in_trial` array provides imputed timestamps for each sample in `muae`;
this lets us recalculate the sampling frequency (eg: 1250 Hz for mice, 1 KHz in
macaque) or plot in the time-dimension without assuming one.

`stim_info` provides the regressors I work for each Trial and each A/B
presentation within the trial, hence each correct trial having four (4)
presentations. The regressors consist of, in this order:

* `stim_info(:, :, 1)`: an element of {0, 1, 2} for non-oddball, local oddball, and global oddball
* `stim_info(:, p, 2)`: the grating orientation for presentation `p` in degrees
* `stim_info(:, :, 3)`: an element of {1, 2, 3} for main block, random control block, or sequence control block
* `stim_info(:, p, 4)`: conditional surprisal (`-log2(Pr(o_p | o_{1:p-1}))`) of presentation `p`. For the block structures the probabilities are:
  * Habituation (first 50 trials): `Pr(o_1 = X) = 1.0`, `Pr(o_2 = X) = 1.0`, `Pr(o_3 = X) = 1.0`, `Pr(o_4 = Y) = 1.0`, where XXXY = AAAB for AAAB sessions/mice and XXXY = BBBA for BBBA sessions/mice.
  * Main Block: `Pr(o_4 = Y | o_{1:3}) = 0.8`, `Pr(o_4 = X | o_{1:3}) = 0.2`, with the other stimuli having `Pr(o_{1,2,3} = X | o_{1:p-1}) = 1`
  * Random Control Block: `Pr(o_p = A | o_{1:p-1}) = 0.5`, `Pr(o_p = B | o_{1:p-1}) = 0.5`
  * Sequence Control Block: `Pr(o_p = A | o_{1:p-1}) = 1.0` for AAAA, `Pr(o_p = B | o_{1:p-1}) = 1.0` for BBBB.

* `stim_info(:, p, 5)`: marginal surprisal of this stimulus, that being how many times this stimulus has previously appeared over how many presentations have taken place this session.
* `stim_info(:, p, 6)`: cumulative conditional surprisal of this presentation, the sum of `stim_info(:, 1:p, 4)`
* `stim_info(:, p, 7)`: cumulative marginal surprisal of this presentation, the sum of `stim_info(:, 1:p, 5)`.

`stim_times` provides the timestamps, in the same units and epoching of time as
in `times_in_trial`, for the fixation and the four presentations in each trial.
Thus:

* `stim_times(:, 1, 1:2)`: onset and offset times of fixation (can be same for fixation)
* `stim_times(:, 2, 1:2)`: onset and offset times of Presentation 1
* `stim_times(:, 3, 1:2)`: onset and offset times of Presentation 2
* `stim_times(:, 4, 1:2)`: onset and offset times of Presentation 3
* `stim_times(:, 5, 1:2)`: onset and offset times of Presentation 4
